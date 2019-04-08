PHONY: \
	all \
	build \
	load-xsd-samples \
	test

all: build load-xsd-samples test

build:
	@echo "Building jar..."
	@mvn -DskipTests clean package
	@echo "Done".
	
load-xsd-samples: ./xsd-samples

./xsd-samples:
	@echo "Loading xsd samples..."
	@-wget -nv -B "https://images-na.ssl-images-amazon.com/images/G/01/rainier/help/xsd/release_1_9/" -i "xsd-url-g01-1_9.list" -P "xsd-samples/"
	@-wget -nv -B "https://images-na.ssl-images-amazon.com/images/G/01/rainier/help/xsd/release_4_1/" -i "xsd-url-g01-4_1.list" -P "xsd-samples/"
	@echo
	@echo "NOTE: xsd2go tool cannot process some of Amazon MWS schemas."
	@echo "May be it's possible with some binding customizations, but for now I just leave only those parts I was able to process."
	@echo "NOTE: If this step fails, then Amazon changed xsd files and patch should be re-created."
	@echo
	@echo "Patching xsd samples to remove some unchewable parts..."
	@patch -s -p0 < xsd-samples.patch
	@echo "Done."

.ONESHELL:
test:
	@echo "Generating Go code for xsd samples..."
	@cd ./target
	@echo "1. Running xjc to generate java code..."
	@xjc -quiet -p model ../xsd-samples
	@echo "2. Compiling generated java code..."
	@cd ./model
	@JAR_PATH=$$(find .. -name *-jar-with-dependencies.jar)
	@javac -cp ".:$${JAR_PATH}" *.java
	@echo "3. Executing xsd2go..."
	@java -jar $${JAR_PATH} . model > ../model-raw.go
	@goimports ../model-raw.go > ../model.go
	@echo "Done."
