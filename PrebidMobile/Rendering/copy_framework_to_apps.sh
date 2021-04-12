FRAMEWORK_NAME="$PRODUCT_NAME.framework"

declare -a destinations=(
"/../OpenXInternalTestApp/OpenXInternalTestApp/OpenXInternalTestApp/Frameworks/"
"/../Products/"
)

for DESTINATION in "${destinations[@]}"
do
    #Construct paths
    echo "Constructing Paths..."
    SOURCE_PATH=$BUILT_PRODUCTS_DIR/$FRAMEWORK_NAME
    DEST_FOLDER=$SOURCE_ROOT/$DESTINATION
    DEST_PATH=$DEST_FOLDER/$FRAMEWORK_NAME

    #Delete the old version
    echo "Deleting Old Version..."
    rm -rf $DEST_PATH

    #Copy in the new version
    echo "Copying..."
    mkdir -p $DEST_FOLDER && cp -r $SOURCE_PATH $DEST_PATH

    #Check results
    ls -lart $FRAMEWORK_PATH
done
