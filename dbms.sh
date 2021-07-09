#! /bin/bash
# -------------------------------helper functions--------------------------------------
# 							$1				$2				$3
# match-data	$REPLY		$file 		$column

function check_dataType {
	datatype=$(head -1 $2 | cut -d ':' -f$3 | awk -F "-" 'BEGIN { RS = ":" } {print $2}')
	if [[ "$1" = '' ]]; then
		echo 1
	elif [[ "$1" = -?(0) ]]; then
		echo 0 # error!
	elif [[ "$1" = ?(-)+([0-9])?(.)*([0-9]) ]]; then
		if [[ $datatype == integer ]]; then
			# datatype integer and the input is integer
			echo 1
		else
			# datatype string and input is integer
			echo 1
		fi
	else
		if [[ $datatype == integer ]]; then
			# datatype integer and input is string
			echo 0 # error!
		else
			# datatype string and input is string
			echo 1
		fi
	fi
}
################################################################################
function check_size {
	datasize=$(head -1 $2 | cut -d ':' -f$3 | awk -F "-" 'BEGIN { RS = ":" } {print $3}')
	if [[ "${#1}" -le $datasize ]]; then
		echo 1
	else
		echo 0 # error
	fi
}
################################################################################
# print separator
function separator {
	# echo -e "\n############################################################\n";
	echo -e "\n************************************************************\n";
}
################################################################################
# Welcome Message
function welcomeMsg {
	echo -e "\n\t\tBash Shell Scripting Project - DBMS\n\tOpen Source Applications Development - Intake 39\n\t\t\t   Mostafa Ali\n";
}

# ------------------------------- database functions --------------------------------------

################################################################################
################################################################################
######### Welcome Screen #######################################################
################################################################################
function welcomeScreen {
	welcomeMsg;
	separator;
	select choice in "Enter to Our Database" "Exit"; do
		case $REPLY in
			1 )
				# echo `pwd`
				if ! [[  -e `pwd`/DB ]]; then
					mkdir -p ./DB
				fi
				cd ./DB/
				# location="./DB"
				# location="$location"
				welcomeScreen=false
				dbsScreen=true
				separator;
				echo -e "\e[42mDatabase is loading...\e[0m"
				echo press any key
				read
				;;
			2 )
				exit
				;;
			* )
				echo -e "\e[41minvalid entry\e[0m"
				echo press any key
				read
				;;
		esac
		break
	done 
}
################################################################################
################################################################################
######### DBs Screen ###########################################################
################################################################################
# create Database
function createDb {
	echo enter the name of the database please
	read dbname
	#############
	# null entry
	if [[ $dbname = "" ]]; then
		echo -e "\e[41minvalid entry, please enter a correct name\e[0m"
		echo press any key
		read
	#############
	# special characters
	elif [[ $dbname =~ [/.:\|\-] ]]; then
		echo -e "\e[41mYou can't enter these characters => . / : - | \e[0m"
		echo press any key
		read
	# elif [[ $dbname == "\\" ]]; then
	# 	echo -e "\e[41mYou can't enter these characters => . / : - | \e[0m"
	# 	echo press any key
	# 	read
	#############
	# db name exists		
	elif [[ -e $dbname ]]; then
		echo -e "\e[41mthis database name is already used\e[0m"
		echo press any key
		read
	#############
	# new DB
	elif [[ $dbname =~ ^[a-zA-Z] ]]; then
		mkdir -p "$dbname"
		cd "./$dbname" > /dev/null 2>&1
		newloc=`pwd`
		if [[ "$newloc" = `pwd` ]]; then
			echo -e "\e[42mdatabase created sucessfully in $(pwd)\e[0m"
			dbsScreen=false
			tablesScreen=true
			echo press any key
			read
		else
			cd - > /dev/null 2>&1
			echo -e "\e[41mcan't access this location\e[0m"
			echo press any key
			read
		fi
	#############
	# numbers or other special characters
	else
		echo -e "\e[41mDatabase name can't start with numbers or special characters\e[0m"
		echo press any key
		read
	fi
}
################################################################################
# use Existing Database
function useExistingDb {
	# set -x
	############
	# no databases exist
	if [[ $(find -maxdepth 1 -type d | cut -d'/' -f2 | sed '1d') = '' ]]; then
		echo -e "\e[44mthere are no databases here\e[0m"
		echo press any key
		read
	############
	# databases exist
	else
		echo Databases:$'\n'$(find -maxdepth 1 -type d | cut -d'/' -f2 | sed '1d')
		separator;
			echo enter the name of the database
			read db
			db="$db"
			############
			# null entry
			if [[ "$db" = '' ]]; then
				echo -e "\e[41minvalid entry, please enter a correct name\e[0m"
				echo press any key
				read
			############
			# db exists
			elif ! [[ -d "$db" ]]; then
				echo -e "\e[41mthis database doesn't exist\e[0m"
				echo press any key
				read
			############
			# new db
			else
				cd "$db"
				separator;
				echo -e "\e[42mthe database successfully loaded\e[0m"
				dbsScreen=false
				tablesScreen=true
				echo press any key
				read
			fi
	fi
	# set +x
}
################################################################################
# drop db
function dropDb {
	echo Databases:$'\n'$(find -maxdepth 1 -type d | cut -d'/' -f2 | sed '1d')
	separator;
	echo enter the name of the database
		read db
		db="$db"
		############
		# null entry
		if [[ "$db" = '' ]]; then
			echo -e "\e[41minvalid entry, please enter a correct name\e[0m"
			echo press any key
			read
		############
		# db exists
		elif ! [[ -d "$db" ]]; then
			echo -e "\e[41mthis database doesn't exist\e[0m"
			echo press any key
			read
		############
		# new db	
		else
			rm -rf "$db"
			echo -e "\e[42m$db removed from your databases\e[0m"
			echo press any key
			read
		fi
}


################################################################################
################################################################################
######### Tables Screen ########################################################
################################################################################
# create tables' metadata
function createMetaData {
	# create the metadata
		if [[ -f "$dbtable" ]]; then
			##########
			# num of cols
			validMetaData=true
			while $validMetaData; do
				echo -e "\e[44mhow many columns you want?\e[0m"
				read num_col
				if [[ "$num_col" = +([1-9])*([0-9]) ]]; then
					validMetaData=false
				else
					echo -e "\e[41minvalid entry\e[0m"
				fi
			done
			##########
			## pk name
			validMetaData=true
			while $validMetaData; do
				echo -e "\e[44menter primary key name\e[0m"
				read pk_name
				#############
				# null entry
				if [[ $pk_name = "" ]]; then
					echo -e "\e[41minvalid entry, please enter a correct name\e[0m"
				#############
				# special characters
				elif [[ $pk_name =~ [/.:\|\-] ]]; then
					echo -e "\e[41mYou can't enter these characters => . / : - | \e[0m"
				############
				# valid entry
				elif [[ $pk_name =~ ^[a-zA-Z] ]]; then
					echo -n "$pk_name" >> "$dbtable"
					echo -n "-" >> "$dbtable"
					validMetaData=false
				#############
				# numbers or other special characters
				else
					echo -e "\e[41m Primary key can't start with numbers or special characters\e[0m"
				fi
			done
			##########
			# pk dataType
			validMetaData=true
			while $validMetaData; do
				echo -e "\e[44menter primary key datatype\e[0m"
				select choice in "integer" "string"; do
					if [[ "$REPLY" = "1" || "$REPLY" = "2" ]]; then
						echo -n "$choice" >> "$dbtable"
						echo -n "-" >> "$dbtable"
						validMetaData=false
					else
						echo -e "\e[41minvalid chioce\e[0m"
					fi
					break
				done
			done
			##########
			# pk size
			validMetaData=true
			while $validMetaData; do
				echo -e "\e[44menter primary key size\e[0m"
				read size
				if [[ "$size" = +([1-9])*([0-9]) ]]; then
					echo -n "$size" >> "$dbtable"
					echo -n ":" >> "$dbtable"
					validMetaData=false
				else
					echo -e "\e[41minvalid entry\e[0m"
				fi
			done
			##########
			## to iterate over the enterd num of columns after the primary key, in order to enter its metadata
			for (( i = 1; i < num_col; i++ )); do
				##########
				# field name
				validMetaData=true
				while $validMetaData; do
					echo -e "\e[46menter field $[i+1] name\e[0m"
					read field_name
					#############
					# null entry
					if [[ $field_name = "" ]]; then
						echo -e "\e[41minvalid entry, please enter a correct name\e[0m"
					#############
					# special characters
					elif [[ $field_name =~ [/.:\|\-] ]]; then
						echo -e "\e[41mYou can't enter these characters => . / : - | \e[0m"
					############
					# valid entry
					elif [[ $field_name =~ ^[a-zA-Z] ]]; then
						echo -n "$field_name" >> "$dbtable"
						echo -n "-" >> "$dbtable"
						validMetaData=false
					#############
					# numbers or other special characters
					else
						echo -e "\e[41mfield name can't start with numbers or special characters\e[0m"
					fi
				done
				##########
				# field dataType
				validMetaData=true
				while $validMetaData; do
					echo -e "\e[46menter field $[i+1] datatype\e[0m"
					select choice in "integer" "string"; do
						if [[ "$REPLY" = "1" || "$REPLY" = "2" ]]; then
							echo -n "$choice" >> "$dbtable"
							echo -n "-" >> "$dbtable"
							validMetaData=false
						else
							echo -e "\e[41minvalid choice\e[0m"
						fi
						break
					done
				done
				##########
				# field size
				validMetaData=true
				while $validMetaData; do
					echo -e "\e[46menter field $[i+1] size please\e[0m"
					read size
					if [[ "$size" = +([1-9])*([0-9]) ]]; then
						echo -n "$size" >> "$dbtable"
						##########
						# if last column
						if [[ i -eq $num_col-1 ]]; then
							echo $'\n' >> "$dbtable"
							echo -e "\n\e[42mtable created successfully\e[0m"
							echo press any key
							read
						##########
						# next column
						else
							echo -n ":" >> "$dbtable"
						fi
						validMetaData=false
					else
						echo -e "\e[41minvalid entry\e[0m"
					fi
				done
				##########
			done
			##########
		else
			echo -e "\e[41minvalid entry\e[0m" 
			echo press any key
			read
		fi
}

################################################################################
# Create Table & its metadata
function createTable {
		##########
		# table name
		echo enter the name of the table please
		read dbtable
		#############
		# null entry
		if [[ $dbtable = "" ]]; then
			echo -e "\e[41minvalid entry, please enter a correct name\e[0m"
			echo press any key
			read
		#############
		# special characters
		elif [[ $dbtable =~ [/.:\|\-] ]]; then
			echo -e "\e[41mYou can't enter these characters => . / : - | \e[0m"
			echo press any key
			read
		#############
		# table name exists
		elif [[ -e "$dbtable" ]]; then
			echo -e "\e[41mthis table name exists\e[0m"
			echo press any key
			read
			# break
		#############
		# new table
		elif  [[ $dbtable =~ ^[a-zA-Z] ]]; then
			touch "$dbtable"
			createMetaData;
		else
			echo -e "\e[41mTable name can't start with numbers or special characters\e[0m"
			echo press any key
			read
		fi
		##########
	# done
}
################################################################################
# delete table
function deleteTable {
	echo enter the name of the table to delete
	read dbtable
	##########
	# not exist
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\e[41mthis table doesn't exist\e[0m"
		echo press any key
		read
	##########
	# exists
	else
		rm "$dbtable"
		echo -e "\e[42mtable deleted\e[0m"
		echo press any key
		read
	fi
}
################################################################################
# insert data into table
function insertData {
	##########
	# choose the table
	echo enter the name of the table
	read dbtable
	##########
	# not exist
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\e[41mthis table doesn't exist\e[0m"
		echo press any key
		read
	else
		##########
		## table exists
		insertingData=true
		while $insertingData ; do
			##########
			# enter pk
			## => enter pk of type "id" of type integer and size 1
			echo -e "enter primary key \"\e[44m$(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $1}')\e[0m\" of type \e[44m$(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $2}')\e[0m and size \e[44m$(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $3}')\e[0m"

			read
			##########
			# match data & size
			check_type=$(check_dataType "$REPLY" "$dbtable" 1)
			check_size=$(check_size "$REPLY" "$dbtable" 1)
			#=> print all records except first record
			pk_used=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}' | grep -x -e "$REPLY") 
			##########
			# null entry
			if [[ "$REPLY" == '' ]]; then
				echo -e "\e[41mno entry\e[0m"
			#############
			# special characters
			elif [[ $REPLY =~ [/.:\|\-] ]]; then
				echo -e "\e[41mYou can't enter these characters => . / : - | \e[0m"
			##########
			# not matching datatype 
			elif [[ "$check_type" == 0 ]]; then 
				echo -e "\e[41mentry invalid\e[0m"
			##########
			# not matching size	
			elif [[ "$check_size" == 0 ]]; then
				echo -e "\e[41mentry size invalid\e[0m"
			##########
			#! if primary key exists
			elif ! [[ "$pk_used" == '' ]]; then
				echo -e "\e[41mthis primary key is already used\e[0m"
			##########
			# primary key is valid
			else 
				echo -n "$REPLY" >> "$dbtable"
				echo -n ':' >> "$dbtable"
				##########
				# to get number of columns in table
				num_col=$(head -1 "$dbtable" | awk -F: '{print NF}')
				## to iterate over the columns after the primary key, in order to enter its data
				for (( i = 2; i <= num_col; i++ )); do
					##########
					# enter other data
					inserting_other_data=true
					while $inserting_other_data ; do
						echo -e "enter \"\e[44m$(head -1 "$dbtable" | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $1}')\e[0m\" of type \e[44m$(head -1 "$dbtable" | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $2}')\e[0m and size \e[44m$(head -1 "$dbtable" | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $3}')\e[0m"

						read
						##########
						# match data with its col datatype & size
						check_type=$(check_dataType "$REPLY" "$dbtable" "$i")
						check_size=$(check_size "$REPLY" "$dbtable" "$i")
						##########
						# not matching datatype
						if [[ "$check_type" == 0 ]]; then
							echo -e "\e[41mentry invalid\e[0m"
						##########
						# not matching size
						elif [[ "$check_size" == 0 ]]; then
							echo -e "\e[41mentry size invalid\e[0m"
						#############
						# special characters
						elif [[ $REPLY =~ [/.:\|\-] ]]; then
							echo -e "\e[41mYou can't enter these characters => . / : - | \e[0m"
						##########
						# entry is valid
						else
							##########
							# if last column
							if [[ i -eq $num_col ]]; then
								echo "$REPLY" >> "$dbtable"
								inserting_other_data=false
								insertingData=false
								echo -e "\e[42mentry inserted successfully\e[0m"
							else
								##########
								# next column 
								echo -n "$REPLY": >> "$dbtable"
								inserting_other_data=false
							fi
						fi
					done
				done
			fi
		done
		echo press any key
		read
	fi
}
################################################################################
# delete record (row)
function deleteRecord {
	##########
	# choose table
	echo enter name of the table
	read dbtable
	##########
	# not exist
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\e[41mthis table doesn't exist\e[0m"
		echo press any key
		read
	else
		##########
		# table exists
		##########
		# enter pk
		echo -e "enter primary key \"\e[44m$(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $1}')\e[0m\" of type \e[44m$(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}')\e[0m and size \e[44m$(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}')\e[0m" of the record to delete
		
		read
		#########
		# get Number of this record
		recordNum=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}'
		| grep -x -n -e "$REPLY" | cut -d':' -f1)
		#! -x => exact match // -e => pattern // -n record number prefix

		##########
		# null entry
		if [[ "$REPLY" == '' ]]; then
			echo -e "\e[41mno entry\e[0m"
		##########
		# record not exists
		elif [[ "$recordNum" = '' ]]; then
			echo -e "\e[41mthis primary key doesn't exist\e[0m"
		##########
		# record exists
		else
			let recordNum=$recordNum+1 #!=> recordNum is 0 based but sed is 1 based
			sed -i "${recordNum}d" "$dbtable"
			echo -e "\e[42mrecord deleted successfully\e[0m"
		fi
		echo press any key
		read
	fi
}
################################################################################
# Update Table
function updateTable {
	##########
	# choose table
	echo enter name of the table
	read dbtable
	##########
	# not exist
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\e[41mthis table doesn\'t exist\e[0m"
		echo press any key
		read
	else
		##########
		# table exists
		##########
		# enter pk
		echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
		awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
		| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
		| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}') of the record
		read
		
		recordNum=$(cut -d ':' -f1 "$dbtable" | sed '1d'\
		| grep -x -n -e "$REPLY" | cut -d':' -f1)
		##########
		# null entry
		if [[ "$REPLY" == '' ]]; then
			echo -e "\e[41mno entry\e[0m"
		##########
		# record not exists
		elif [[ "$recordNum" = '' ]]; then
			echo -e "\e[41mthis primary key doesn't exist\e[0m"
		##########
		# record exists
		else
			let recordNum=$recordNum+1
			##########
			# to get number of columns in table
			num_col=$(head -1 "$dbtable" | awk -F: '{print NF}') 
			##########
			# to show the other values of record
			separator;
			echo -e "\e[42mother fields and values of this record:\e[0m"
			for (( i = 2; i <= num_col; i++ )); do
					echo \"$(head -1 $dbtable | cut -d ':' -f$i |\
					awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable" | cut -d ':' -f$i |\
					awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable" | cut -d ':' -f$i |\
					awk -F "-" 'BEGIN { RS = ":" } {print $3}'): $(sed -n "${recordNum}p" "$dbtable" | cut -d: -f$i)
			done
			separator;
			##########
			# to show the other fields' names of this record
			echo -e "\e[42mrecord fields:\e[0m"
			option=$(head -1 $dbtable | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}')
			echo "$option"
			getFieldName=true
			while $getFieldName; do
				separator;
				echo enter field name to update
				read
				##########
				# null entry
				if [[ "$REPLY" = '' ]]; then
					echo -e "\e[41minvalid entry\e[0m"
				##########
				# field name not exists
				elif [[ $(echo "$option" | grep -x "$REPLY") = "" ]]; then
					echo -e "\e[41mno such field with the entered name, please enter a valid field name\e[0m"
				##########
				# field name exists
				else
					# get field number
					fieldnum=$(head -1 "$dbtable" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}'\
					| grep -x -n "$REPLY" | cut -d: -f1)
					updatingField=true
					while $updatingField; do
						##########
						# updating field's primary key
						if [[ "$fieldnum" = 1 ]]; then
							echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
							awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
							| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
							| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}')

							read
							check_type=$(check_dataType "$REPLY" "$dbtable" 1)
							check_size=$(check_size "$REPLY" "$dbtable" 1)
							pk_used=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}' | grep -x -e "$REPLY")
							##########
							# null entry
							if [[ "$REPLY" == '' ]]; then
								echo -e "\e[41mno entry, id can't be null\e[0m"
							##########
							#match datatype
							elif [[ "$check_type" == 0 ]]; then
								echo -e "\e[41mentry invalid\e[0m"
							##########
							# not matching size
							elif [[ "$check_size" == 0 ]]; then
								echo -e "\e[41mentry size invalid\e[0m"
							##########
							# pk is used
							elif ! [[ "$pk_used" == '' ]]; then
								echo -e "\e[41mthis primary key already used\e[0m"
							##########
							# pk is valid
							else 
								awk -v fn="$fieldnum" -v rn="$recordNum" -v nv="$REPLY"\
								'BEGIN { FS = OFS = ":" } { if(NR == rn)	$fn = nv } 1' "$dbtable"\
								> "$dbtable".new && rm "$dbtable" && mv "$dbtable".new "$dbtable"
								updatingField=false
								getFieldName=false
							fi
						##########
						# updating other field 
						else
							updatingField=true
							while $updatingField ; do
								echo enter \"$(head -1 $dbtable | cut -d ':' -f$fieldnum |\
								awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable" | cut -d ':' -f$fieldnum |\
								awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable" | cut -d ':' -f$fieldnum |\
								awk -F "-" 'BEGIN { RS = ":" } {print $3}')
								read
								check_type=$(check_dataType "$REPLY" "$dbtable" "$fieldnum")
								check_size=$(check_size "$REPLY" "$dbtable" "$fieldnum")
								##########
								# match datatype
								if [[ "$check_type" == 0 ]]; then
									echo -e "\e[41mentry invalid\e[0m"
								##########
								# not matching size
								elif [[ "$check_size" == 0 ]]; then
									echo -e "\e[41mentry size invalid\e[0m"
								##########
								# entry is valid
								else
									awk -v fn="$fieldnum" -v rn="$recordNum" -v nv="$REPLY"\
									'BEGIN { FS = OFS = ":" } { if(NR == rn)	$fn = nv } 1' "$dbtable"\
									> "$dbtable".new && rm "$dbtable" && mv "$dbtable".new "$dbtable"
									updatingField=false
									getFieldName=false
								fi
							done
						fi
					done
					echo -e "\e[42mfield updated successfully\e[0m"
				fi
			done
		fi
		echo press any key
		read
	fi
}
################################################################################
# Display Record (Row)
function displayRow {
	##########
	# choose table
	echo enter name of the table
	read dbtable
	##########
	# not exist
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\e[41mthis table doesn't exist\e[0m"
		echo press any key
		read
	else
		##########
		## table exists
		##########
		# enter pk
		echo enter primary key \"$(head -1 "$dbtable" | cut -d ':' -f1 |\
		awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" of type $(head -1 "$dbtable"\
		| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') and size $(head -1 "$dbtable"\
		| cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $3}') of the record
		read
		
		recordNum=$(cut -d ':' -f1 "$dbtable" | sed '1d'\
		| grep -x -n -e "$REPLY" | cut -d':' -f1)
		##########
		# null entry
		if [[ "$REPLY" == '' ]]; then
			echo -e "\e[41mno entry\e[0m"
		##########
		# record not exists
		elif [[ "$recordNum" = '' ]]; then
			echo -e "\e[41mthis primary key doesn't exist\e[0m"
		##########
		# record exists
		else
			let recordNum=$recordNum+1
			num_col=$(head -1 "$dbtable" | awk -F: '{print NF}') 
			##########
			# to show the other values of record
			separator;
			echo -e "\e[42mfields and values of this record:\e[0m"
			for (( i = 2; i <= num_col; i++ )); do
					echo \"$(head -1 $dbtable | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $1}')\" : $(sed -n "${recordNum}p" "$dbtable" | cut -d: -f$i)
			done
			separator;
		fi
		echo press any key
		read
	fi
}
################################################################################
# Display Table
function displayTable {
	##########
	# choose table
	echo enter name of the table
	read dbtable
	##########
	# not exist
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\e[41mthis table doesn't exist\e[0m"
		echo press any key
		read
	else
		##########
		## table exists
		##########
		# display table's data
		echo "------------------------------------------------------------"
		head -1 "$dbtable" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}' | awk 'BEGIN{ORS="\t"} {print $0}'
		echo -e "\n------------------------------------------------------------"
		sed '1d' "$dbtable" | awk -F: 'BEGIN{OFS="\t"} {for(n = 1; n <= NF; n++) $n=$n}  1'
		echo $'\n'press any key
		read
	fi
}

################################################################################
################################################################################
####### GUI ####################################################################
################################################################################

welcomeScreen=true
dbsScreen=true
tablesScreen=true
while true; do
################################################################################
	# welcome screen 
	while $welcomeScreen; do	
		clear
		separator;
		welcomeScreen;
	done
	################################################################################
	# Databases Screen
	while $dbsScreen; do
		clear
		separator;
		echo -e "\t\tYour Existing Databases:\n$(find -maxdepth 1 -type d | cut -d'/' -f2 | sed '1d')"
		separator;
		select choice in "Create a new database" "Use existing Database" "Drop Database" "Back"; do 
		case $REPLY in
			1 ) # Create a database
				separator;
				createDb;
				;;
			2 ) # Use existing
				separator;
				useExistingDb;
				;;
			3 ) # Drop Database
				separator;
				dropDb;
				;;
			4 ) # Back
				cd ..
				welcomeScreen=true
				dbsScreen=false
				tablesScreen=false
				;;
			* )
				echo -e "\e[41minvalid entry\e[0m"
				echo press any key
				read
				;;
		esac
		break
		done
	done
	################################################################################
	#Tables Screen
	while $tablesScreen; do
		clear
		separator;
		echo -e "\t\tYour Existing Tables:\n$(find -maxdepth 1 -type f | cut -d'/' -f2)"
		separator;
		select choice in "Create table" "Delete table" "Insert into table" "Delete row" "Update table" "Display row" "Display table" "Back"; do 
			case $REPLY in
				1 ) # create table
					separator;
					createTable;
					;;
					##########
				2 ) # delete table
					separator;
					deleteTable;
					;;
					##########
				3 ) # insert into table
					separator;
					insertData;
					;;
					##########
				4 ) # delete record
					separator;
					deleteRecord;
					;;
					##########
				5 ) # update table
					separator;
					updateTable;
					;;
					##########
				6 ) # display row
					separator;
					displayRow;
					;;
				7 ) # display table
					separator;
					displayTable;
					;;
				8 ) # back
					cd ..
					welcomeScreen=false
					dbsScreen=true
					tablesScreen=false
					;;
				* )
					echo -e "\e[41minvalid entry\e[0m"
					echo press any key
					read
					;;
			esac
			break
		done
	done
################################################################################
done
