#/bin/bash

#aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text; > instance-list.txt 
>/home/pushkar/rds-metrics.txt

td=`date +%F| sed 's/-//g'`;
d1=2;
diff=`expr $td - $d1`;
echo $diff;
echo $td;
#while read line
	for i in `aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text`; 
	do 
#aws rds describe-db-snapshots --db-instance-identifier=$i --query 'DBSnapshots[*].[DBInstanceIdentifier,Engine,DBSnapshotIdentifier,Status]' --output text

#aws rds describe-db-snapshots --db-instance-identifier=$i --query 'DBSnapshots[*].[DBInstanceIdentifier,Engine,DBSnapshotIdentifier,Status]' --output text | tail -1;
#	echo $v1
DBInstanceIdentifier=`aws rds describe-db-snapshots --db-instance-identifier=$i --query 'DBSnapshots[*].[DBInstanceIdentifier]' --output text | tail -1 | awk '{ print $1 }'`
echo $DBInstanceIdentifier
Engine=`aws rds describe-db-snapshots --db-instance-identifier=$i --query 'DBSnapshots[*].[Engine]' --output text | tail -1 | awk '{ print $1 }'`
	DBSnapshotIdentifier=`aws rds describe-db-snapshots --db-instance-identifier=$i --query 'DBSnapshots[*].[DBSnapshotIdentifier]' --output text | tail -1 | awk '{ print $1 }'`
	
Status=`aws rds describe-db-snapshots --db-instance-identifier=$i --query 'DBSnapshots[*].[Status]' --output text | tail -1 | awk '{ print $1 }'`
SnapshotCreateTime=`aws rds describe-db-snapshots --db-instance-identifier=$i --query 'DBSnapshots[*].[SnapshotCreateTime]' --output text | tail -1| cut -d "=" -f2 | cut -d "T" -f1 | sed 's/-//g'`
Backupdate=`echo "$SnapshotCreateTime" | cut -d "=" -f2`;
echo "Backupdateis $Backupdate and Diff date is $diff"
s=`echo "available"`
	if [ $Backupdate -gt $diff ];then
#Backup is done ok 

	#echo "rds_backup_status{DBInstances=\"$i\",Engine=\"$Engine\" DBSnapshotIdentifier=\"$DBSnapshotIdentifier\" Status=\"$Status\" SnapshotCreateTime=\"$SnapshotCreateTime\"}" 0 >> /home/pushkar/rds-metrics.txt 
		if [ $Status == $s ]; then
			echo "rds_backup_status{DBInstances=\"$i\",Engine=\"$Engine\" DBSnapshotIdentifier=\"$DBSnapshotIdentifier\" Status=\"$Status\" SnapshotCreateTime=\"$SnapshotCreateTime\"}" 0 >> /home/pushkar/rds-metrics.txt 
		else 
	        	echo "rds_backup_status{DBInstances=\"$i\",Engine=\"$Engine\" DBSnapshotIdentifier=\"$DBSnapshotIdentifier\" Status=\"$Status\" SnapshotCreateTime=\"$SnapshotCreateTime\"}" 1 >> /home/pushkar/rds-metrics.txt
		fi	
	else
	echo "rds_backup_status{DBInstances=\"$i\",Engine=\"$Engine\" DBSnapshotIdentifier=\"$DBSnapshotIdentifier\" Status=\"$Status\" SnapshotCreateTime=\"$SnapshotCreateTime\"}" 1 >> /home/pushkar/rds-metrics.txt
	fi

done;

