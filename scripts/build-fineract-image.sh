#!/usr/bin/env bash
set -Eeuo pipefail

# Rebuild the Fineract API image using the same build shape used by the
# successful deployment pipeline. Pin FINERACT_SOURCE_REF to a reviewed
# Apache Fineract tag or commit for reproducible builds.

: "${FINERACT_SOURCE_REF:?Set FINERACT_SOURCE_REF to a reviewed Apache Fineract tag or commit}"

JAVA_REQUIRED="25.0.5"
GRADLE_VERSION="9.7.1"
MARIADB_VERSION="3.5.7"
IMAGE_NAME="${FINERACT_IMAGE_NAME:-fineract-api}"
IMAGE_TAG="${FINERACT_IMAGE_TAG:-local}"
JIB_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

command -v git >/dev/null
command -v java >/dev/null
command -v docker >/dev/null
command -v wget >/dev/null
command -v unzip >/dev/null

java -version 2>&1 | grep -F "$JAVA_REQUIRED" >/dev/null || {
  echo "Expected Java ${JAVA_REQUIRED}. Install the matching Temurin JDK first." >&2
  exit 1
}

BUILD_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$BUILD_ROOT"; }
trap cleanup EXIT

SOURCE_DIR="$BUILD_ROOT/fineract-source"
MARIADB_DIR="$BUILD_ROOT/mariadb-runtime"
MARIADB_JAR="mariadb-java-client-${MARIADB_VERSION}.jar"
mkdir -p "$MARIADB_DIR"

echo "Cloning Apache Fineract source..."
git clone https://github.com/apache/fineract.git "$SOURCE_DIR"
git -C "$SOURCE_DIR" checkout --detach "$FINERACT_SOURCE_REF"
FINERACT_COMMIT="$(git -C "$SOURCE_DIR" rev-parse HEAD)"
echo "Fineract source commit: ${FINERACT_COMMIT}"

test -f "$SOURCE_DIR/gradlew"
test -f "$SOURCE_DIR/fineract-provider/build.gradle"
chmod +x "$SOURCE_DIR/gradlew"

echo "Downloading MariaDB Connector/J ${MARIADB_VERSION}..."
wget -q \
  "https://repo.maven.apache.org/maven2/org/mariadb/jdbc/mariadb-java-client/${MARIADB_VERSION}/${MARIADB_JAR}" \
  -O "$MARIADB_DIR/$MARIADB_JAR"

test -s "$MARIADB_DIR/$MARIADB_JAR"
unzip -l "$MARIADB_DIR/$MARIADB_JAR" \
  | grep -F 'org/mariadb/jdbc/Driver.class' >/dev/null

# This disposable upstream checkout receives the same Jib runtime-classpath
# overlay used by the successful deployment build. Upstream is not forked.
cat >> "$SOURCE_DIR/fineract-provider/build.gradle" <<GRADLE

// Project Atlas build overlay: MariaDB Connector/J runtime driver.
jib {
    extraDirectories {
        paths {
            path {
                from = file('${MARIADB_DIR}')
                into = '/app/libs'
            }
        }
    }
    container {
        extraClasspath = [
            '/app/libs/${MARIADB_JAR}'
        ]
    }
}
GRADLE

WRAPPER_FILE="$SOURCE_DIR/gradle/wrapper/gradle-wrapper.properties"
test -f "$WRAPPER_FILE"
sed -i \
  "s#^distributionUrl=.*#distributionUrl=https\\\\://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip#" \
  "$WRAPPER_FILE"

cd "$SOURCE_DIR"
./gradlew --version

echo "Building ${JIB_IMAGE}..."
./gradlew \
  :fineract-provider:jibDockerBuild \
  -x test \
  --no-daemon \
  --no-parallel \
  --max-workers=2 \
  '-Dorg.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=768m -Dfile.encoding=UTF-8' \
  "-Djib.to.image=${JIB_IMAGE}"

docker image inspect "$JIB_IMAGE" >/dev/null
IMAGE_CONTAINER="$(docker create "$JIB_IMAGE")"
cleanup_container() { docker rm -f "$IMAGE_CONTAINER" >/dev/null 2>&1 || true; }
docker cp "${IMAGE_CONTAINER}:/app/libs/${MARIADB_JAR}" "$BUILD_ROOT/$MARIADB_JAR"
docker cp "${IMAGE_CONTAINER}:/app/jib-classpath-file" "$BUILD_ROOT/jib-classpath-file"
test -s "$BUILD_ROOT/$MARIADB_JAR"
grep -F "/app/libs/${MARIADB_JAR}" "$BUILD_ROOT/jib-classpath-file" >/dev/null
unzip -l "$BUILD_ROOT/$MARIADB_JAR" | grep -F 'org/mariadb/jdbc/Driver.class' >/dev/null
cleanup_container
trap cleanup EXIT

echo "SUCCESS: ${JIB_IMAGE} built with MariaDB Connector/J on the Jib classpath."
echo "Fineract source commit: ${FINERACT_COMMIT}"
