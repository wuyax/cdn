url="https://cdnjs.cloudflare.com/ajax/libs/react-dom/16.7.0/umd/react-dom.production.min.js"
echo ${url}
fullName=${url##*/}
echo ${fullName}
fileName=${fullName%%.*}
echo ${fileName}
fileType=${fullName##*.}
echo ${fileType}
version=1.0.1

curl -o ./${fileType}/${fileName}/${version}/${fullName} --create-dirs ${url}