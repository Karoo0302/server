apt-get install -y rsync

echo "Rsync Source Path :"
read source_path

echo "Rsync Destination Path :"
read des_path

echo '
check=`diff -r source_path des_path -q -x "*.*.*"`
if [ -n "$check" ]
then
        addfile_src=`diff -r source_path des_path -q | grep "Files" | cut -d " " -f 2`
        addfile_des=`diff -r source_path des_path -q | grep "Files" | cut -d " " -f 4`
        addfile_num=`echo $addfile_src | wc -w`
        if [ "0" != $addfile_num ]
        then
                for (( i=1; i<=$addfile_num; i++))
                do
                        target_src=`echo $addfile_src | cut -d " " -f $i`
                        target_des=`echo $addfile_des | cut -d " " -f $i`
                        echo -e $i"/"$addfile_num" src:" $target_src"\t\t\tdes:" $target_des
                        rsync -r --backup --suffix=`date +'.%F_%H-%M-%S'` $target_src $target_des
                done
        fi

        echo "adding file rcync success"

        nonefile_dir=`diff -r source_path des_path -q | grep -v "des_path:" | cut -d ":" -f 1 | cut -d " " -f 3`
        nonefile_file=`diff -r source_path des_path -q | grep -v "des_path:" | cut -d " " -f 4`
        nonefile_num=`echo $nonefile_dir | wc -w`

        if [ "0" != $nonefile_num ]
        then
                for (( i=1; i<=$nonefile_num; i++))
                do
                        target_dir=`echo $nonefile_dir | cut -d " " -f $i`
                        target_subdir="/"`echo $target_dir | tr -d "source_path"`
                        target_file="/"`echo $nonefile_file | cut -d " " -f $i`
                        target_src="source_path"${target_subdir}${target_file}
                        target_des="des_path"$target_subdir
                        echo -e $i"/"$nonefile_num "src :" $target_src"\t\t\tdes :" $target_des
                        rsync -r --backup --suffix=`date +".%F_%H-%S"` $target_src $target_des
                done
        fi

        echo "empty file rcync success"

fi' >> backup.sh

sed -i "s|source_path|$source_path|g" backup.sh
sed -i "s|des_path|$des_path|g" backup.sh

