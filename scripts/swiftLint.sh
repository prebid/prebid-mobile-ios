if [ -d "scripts" ]; then
cd scripts/
fi

cd ../src/PrebidMobile/
echo $PWD

echo "Installing SwiftLint"

brew update && brew install swiftlint

echo "Running SwiftLint"

swiftlint
