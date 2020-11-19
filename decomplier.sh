#!/bin/bash
if [ $# != 2 ] ; then
    echo "$0 \${WEB_ROOT} \${Package Name}"
    echo "e.g. decomplier.sh /Users/makato/Downloads/xxx com.xxx\\*"
    exit 1;
fi
WEB_ROOT=$1
if [ ! -d "$WEB_ROOT/WEB-INF" ] ; then
    echo -e "\033[31m can't found WEB-INF \033[0m"
    exit 1;
fi
if [ -d "$WEB_ROOT/WEB-INF/lib" ] ; then
    if [ -d "$WEB_ROOT/WEB-INF/lib_decomplied" ] ; then
        rm -rf $WEB_ROOT/WEB-INF/lib_decomplied
    fi
    mkdir $WEB_ROOT/WEB-INF/lib_decomplied
    for lib in `find $WEB_ROOT/WEB-INF/lib/ -type f -name "*.jar" |xargs grep "$2" |awk '{print $3}'`
    do
        echo -e "\033[32m Decompiling $lib \033[0m"
        java -cp java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dgs=true $lib $WEB_ROOT/WEB-INF/lib_decomplied >> /dev/null 2>&1
    done
fi
if [ -d "$WEB_ROOT/WEB-INF/classes" ] ; then
    if [ -d "$WEB_ROOT/WEB-INF/classes_decomplied" ] ; then
        rm -rf $WEB_ROOT/WEB-INF/classes_decomplied
    fi
    cp -r $WEB_ROOT/WEB-INF/classes $WEB_ROOT/WEB-INF/classes_decomplied
    for class in `find $WEB_ROOT/WEB-INF/classes_decomplied -type f -name "*.class"`
    do
        echo -e "\033[32m Decompiling $class \033[0m"
        java -cp java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dgs=true $class ${class%/*.class} >> /dev/null 2>&1
        rm $class
    done
fi
for zip in `ls $WEB_ROOT/WEB-INF/lib_decomplied|grep .jar`
do
    echo -e "\033[32m Extracting $zip \033[0m"
    mkdir $WEB_ROOT/WEB-INF/lib_decomplied/${zip%.jar}
    tar -xf $WEB_ROOT/WEB-INF/lib_decomplied/$zip -C $WEB_ROOT/WEB-INF/lib_decomplied/${zip%.jar}
    rm $WEB_ROOT/WEB-INF/lib_decomplied/$zip
done
