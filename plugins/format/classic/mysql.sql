# 5.2.2
DROP TABLE IF EXISTS Prelude_Alert;
CREATE TABLE Prelude_Alert (
 ident INT(8) NOT NULL,	# initialized by prelude-manager (but optional in the draft)
 PRIMARY KEY (ident)
);


# 5.2.2.1
DROP TABLE IF EXISTS Prelude_ToolAlert;
CREATE TABLE Prelude_ToolAlert (
 alert_ident INT(8) NOT NULL,	
 name VARCHAR(255) NOT NULL, # the tool used during the attack
 command VARCHAR(255) NULL,
 PRIMARY KEY (alert_ident)
);


# 5.2.2.2
DROP TABLE IF EXISTS Prelude_CorrelationAlert;
CREATE TABLE Prelude_CorrelationAlert (
 ident INT(8) NOT NULL,	# generated by prelude-manager, it identifies a group of correlated alerts
 name VARCHAR(255) NOT NULL,
 PRIMARY KEY (ident)
);

# 5.2.2.2
DROP TABLE IF EXISTS Prelude_CorrelationAlert_Alerts;
CREATE TABLE Prelude_CorrelationAlert_Alerts (         
       # This is the list of alerts related that are grouped by a correlation
       # This is not explicitly in the draft, but we need it because of the 5.2.2.2 describing the CorrelationAlert Class
 ident INT(8) NOT NULL,
 alert_ident INT(8) NOT NULL,
PRIMARY KEY (ident,alert_ident)
);

# 5.2.2.3
DROP TABLE IF EXISTS Prelude_OverflowAlert;
CREATE TABLE Prelude_OverflowAlert (
 alert_ident INT(8) NOT NULL,	# alert_ident of the associated Alert
 program VARCHAR(255) NOT NULL,
 size INTEGER NULL,
 buffer TEXT NULL,
 PRIMARY KEY (alert_ident)
);

# 5.2.3
DROP TABLE IF EXISTS Prelude_Heartbeat;
CREATE TABLE Prelude_Heartbeat (
 ident INT(8) NOT NULL,
PRIMARY KEY (ident)
);

# 5.2.4.1 
DROP TABLE IF EXISTS Prelude_Analyzer;
CREATE TABLE Prelude_Analyzer (
 parent_ident INT(8) NOT NULL, # Ident of an alert or of an heartbeat
 parent_type VARCHAR(1) NOT NULL, # A=Alert H=Hearbeat
 ident INT(8) NOT NULL DEFAULT '1', 
 analyzerid VARCHAR(255) NOT NULL,
 manufacturer VARCHAR(255) NULL,  # Compliant with Draft v5 (new attribute in the v5)
 model VARCHAR(255) NULL,	# Compliant with Draft v5 (new attribute in the v5)
 version VARCHAR(255) NULL,	# Compliant with Draft v5 (new attribute in the v5)
 class VARCHAR(255) NULL,	# Compliant with Draft v5 (new attribute in the v5)
 ostype VARCHAR(255) NULL,	# Compliant with Draft v6 (new attribute in the v6)
 osversion VARCHAR(255) NULL,	# Compliant with Draft v6 (new attribute in the v6)
PRIMARY KEY (parent_ident,parent_type,ident),
INDEX (model),
INDEX (analyzerid)
);

# 5.2.4.2
DROP TABLE IF EXISTS Prelude_Classification;
CREATE TABLE Prelude_Classification (
 alert_ident INT(8) NOT NULL, # Ident of an alert
 origin ENUM("unknown","bugtraqid","cve","vendor-specific") DEFAULT "unknown" NOT NULL,
 name VARCHAR(255) NOT NULL,
 url VARCHAR(255) NOT NULL,
INDEX (alert_ident),
INDEX (name)
);

# 5.2.4.3
DROP TABLE IF EXISTS Prelude_Source;
CREATE TABLE Prelude_Source (
 alert_ident INT(8) NOT NULL, # Ident of an alert
 ident INT(8) NOT NULL,   # Ident of the source, GENERATED by prelude manager ; this is a counter of sources for a given alert
 spoofed ENUM("unknown","yes","no") DEFAULT "unknown" NULL,
 interface VARCHAR(255) NULL, 
PRIMARY KEY (alert_ident,ident)
);

# 5.2.4.4
DROP TABLE IF EXISTS Prelude_Target;
CREATE TABLE Prelude_Target (
 alert_ident INT(8) NOT NULL, # Ident of an alert
 ident INT(8) NOT NULL,   # Ident of the target, GENERATED by prelude manager ; this is a counter of targets for a given alert
 decoy ENUM("unknown","yes","no") DEFAULT "unknown" NULL,
 interface VARCHAR(255) NULL,
PRIMARY KEY (alert_ident,ident)
);


# 5.2.7.5
DROP TABLE IF EXISTS Prelude_FileList;
CREATE TABLE Prelude_FileList ( # This table is only here to have full compliance.
 alert_ident INT(8) NOT NULL,
 target_ident INT(8) NOT NULL,
PRIMARY KEY(alert_ident,target_ident)
);

DROP TABLE IF EXISTS Prelude_File; 
CREATE TABLE Prelude_File (
 ident INT(8) NOT NULL,
 alert_ident INT(8) NOT NULL,
 target_ident INT(8) NOT NULL,
 path VARCHAR(255) NOT NULL,
 name VARCHAR(255) NOT NULL,
 category ENUM("current", "original") NULL,
 create_time DATETIME NULL,
 modify_time DATETIME NULL,
 access_time DATETIME NULL,
 data_size INT NULL,
 disk_size INT NULL,
#PRIMARY KEY(alert_ident,target_ident,path,name)
INDEX (alert_ident,target_ident, ident)
);

# 5.2.7.5.1
DROP TABLE IF EXISTS Prelude_FileAccess;
CREATE TABLE Prelude_FileAccess (
 alert_ident INT(8) NOT NULL,
 target_ident INT(8) NOT NULL,
 file_ident INT(8) NOT NULL,
 path_file VARCHAR(255) NOT NULL,
 name_file VARCHAR(255) NOT NULL,
 userId_ident INT(8) NOT NULL,
 permission VARCHAR(255) NULL, # "permission" is NOT really COMPLIANT WITH THE DRAFT because we regroup all the permissions in only one argument called permission(TODO?)
#PRIMARY KEY(alert_ident,target_ident,path_file,name_file,userId_ident)
# FileAccess is only used for Targets Files and Target UserId.
# In the Table UserId, parent_type=T and parnt_ident=target_ident
INDEX (alert_ident,target_ident, file_ident)
);

DROP TABLE IF EXISTS Prelude_Linkage;
CREATE TABLE Prelude_Linkage (
 alert_ident INT(8) NOT NULL,
 target_ident INT(8) NOT NULL,
 file_ident INT(8) NOT NULL,
 name VARCHAR(255) NOT NULL,	# path of the dest file (linked file)
 path VARCHAR(255) NOT NULL,	# name of the dest file (linked file)
 category ENUM("hard-link","mount-point","reparse-point","shortcut","stream","symbolic-link") NOT NULL,
INDEX (alert_ident,target_ident, file_ident)
);

DROP TABLE IF EXISTS Prelude_Inode;
CREATE TABLE Prelude_Inode (
 alert_ident INT(8) NOT NULL,
 target_ident INT(8) NOT NULL,
 file_ident INT(8) NOT NULL,
 path_file VARCHAR(255) NOT NULL,
 name_file VARCHAR(255) NOT NULL,
 change_time DATETIME NULL,
 number INT NULL,
 major_device INT NULL,
 minor_device INT NULL,
 c_major_device INT NULL,
 c_minor_device INT NULL,
#PRIMARY KEY(alert_ident,target_ident,path_file,name_file) 
INDEX (alert_ident,target_ident, file_ident) 
);


# 5.2.4.5
DROP TABLE IF EXISTS Prelude_Assessment; # added to be compliant with v6 (could be deleted, but we don't know if they gonna change it in the future... like that, it's safe)
CREATE TABLE Prelude_Assessment (
 alert_ident INT(8) NOT NULL, # Ident of an alert 
PRIMARY KEY (alert_ident)
);


# 5.2.6.1
DROP TABLE IF EXISTS Prelude_Impact;
CREATE TABLE Prelude_Impact (
 alert_ident INT(8) NOT NULL,
 description VARCHAR(255) NULL,	# content of an Impact element
 severity ENUM("low","medium","high") NULL,
 completion ENUM("failed", "succeeded") NULL,
 type ENUM("admin", "dos", "file", "recon", "user", "other") DEFAULT "other" NULL,
PRIMARY KEY(alert_ident),
INDEX (severity),
INDEX (completion)
);

# 5.2.6.2
DROP TABLE IF EXISTS Prelude_Action;
CREATE TABLE Prelude_Action (
 alert_ident INT(8) NOT NULL,
 description VARCHAR(255) NULL,
 category ENUM("block-installed", "notification-sent", "taken-offline", "other") DEFAULT "other" NOT NULL,
PRIMARY KEY(alert_ident)
);

# 5.2.6.3
DROP TABLE IF EXISTS Prelude_Confidence;
CREATE TABLE Prelude_Confidence (
 alert_ident INT(8) NOT NULL,
 confidence FLOAT NULL,	# should be between 0.0 and 1.0
 rating ENUM("low", "medium", "high", "numeric") DEFAULT "numeric" NOT NULL,
PRIMARY KEY(alert_ident)
);



# 5.2.4.6
DROP TABLE IF EXISTS Prelude_AdditionalData;
CREATE TABLE Prelude_AdditionalData (
 parent_ident INT(8) NOT NULL, # Ident of an alert or of an heartbeat
 parent_type VARCHAR(1) NOT NULL, # A=Alert H=Hearbeat
 type ENUM("boolean","byte","character","date-time","integer","ntpstamp","portlist","real","string","xml") DEFAULT "string" NOT NULL,
 meaning VARCHAR(255) NULL, # NULL ?
 data TEXT NULL,		# this is the content of the AdditionalData itself
INDEX (parent_ident,parent_type),
INDEX (meaning)
);

# 5.2.5.1
DROP TABLE IF EXISTS Prelude_CreateTime;
CREATE TABLE Prelude_CreateTime (
 parent_ident INT(8) NOT NULL, # Ident of an alert or of an heartbeat
 parent_type VARCHAR(1) NOT NULL, # A=Alert H=Hearbeat
 time DATETIME NOT NULL,	# this is the content of the CreateTime itself
 ntpstamp VARCHAR(21) NOT NULL,
PRIMARY KEY (parent_ident,parent_type),
INDEX (time)
);

# 5.2.5.2
DROP TABLE IF EXISTS Prelude_DetectTime;
CREATE TABLE Prelude_DetectTime (
 alert_ident INT(8) NOT NULL,	# Ident of an alert
 time DATETIME NOT NULL,	
 ntpstamp VARCHAR(21) NOT NULL,
PRIMARY KEY (alert_ident),
INDEX (time)
);

# 5.2.5.3
DROP TABLE IF EXISTS Prelude_AnalyzerTime;
CREATE TABLE Prelude_AnalyzerTime (
 parent_ident INT(8) NOT NULL, # Ident of an alert or of an heartbeat
 parent_type VARCHAR(1) NOT NULL, # A=Alert H=Hearbeat
 time DATETIME NOT NULL,
 ntpstamp VARCHAR(21) NOT NULL,
PRIMARY KEY (parent_ident,parent_type),
INDEX (time)
);

# 5.2.7.1
DROP TABLE IF EXISTS Prelude_Node;
CREATE TABLE Prelude_Node (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # A=Analyzer T=Target S=Source
 parent_ident INT(8) NOT NULL,
 category ENUM("unknown","ads","afs","coda","dfs","dns","hosts","kerberos","nds","nis","nisplus","nt","wfw") DEFAULT "unknown" NULL, # added "hosts" from the IDMEF v6
 location VARCHAR(255) NULL,
 name VARCHAR(255) NULL,
PRIMARY KEY (alert_ident,parent_type,parent_ident)
);

# 5.2.7.1.1
DROP TABLE IF EXISTS Prelude_Address;
CREATE TABLE Prelude_Address (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # A=Analyser T=Target S=Source
 parent_ident INT(8) NOT NULL,
 category ENUM("unknown","atm","e-mail","lotus-notes","mac","sna","vm","ipv4-addr","ipv4-addr-hex","ipv4-net","ipv4-net-mask","ipv6-addr","ipv6-addr-hex","ipv6-net","ipv6-net-mask") DEFAULT "unknown" NULL,
 vlan_name VARCHAR(255) NULL,	# CAREFULL : The draft specify vlan-name but mysql prefers vlan_name. So here it's not fully compliant 
 vlan_num INTEGER NULL,		# CAREFULL : The draft specify vlan-name but mysql prefers vlan_name. So here it's not fully compliant 
 address VARCHAR(255) NOT NULL,
 netmask VARCHAR(255) NULL,
INDEX (alert_ident,parent_type,parent_ident),
INDEX (address)
);

# 5.2.7.2
DROP TABLE IF EXISTS Prelude_User;
CREATE TABLE Prelude_User (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # T=Target S=Source
 parent_ident INT(8) NOT NULL,
 category ENUM("unknown","application","os-device") DEFAULT "unknown" NULL,
PRIMARY KEY (alert_ident,parent_type,parent_ident)
);

# 5.2.7.2.1
DROP TABLE IF EXISTS Prelude_UserId;
CREATE TABLE Prelude_UserId (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL,	# T=Target S=Source 
 parent_ident INT(8) NOT NULL,
 ident INT(8) NOT NULL, #generated by prelude manager, this is a counter for one alert and one target (or one source)
 type ENUM("current-user","original-user","target-user","user-privs","current-group","group-privs","other-privs") DEFAULT "original-user" NULL, # added "other-privs" from the IDMEF v6
 name VARCHAR(255) NULL,
 number VARCHAR(255) NULL,
PRIMARY KEY (alert_ident,parent_type,parent_ident,ident)
);

# 5.2.7.3
DROP TABLE IF EXISTS Prelude_Process;
CREATE TABLE Prelude_Process (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # A=Analyzer T=Target S=Source
 parent_ident INT(8) NOT NULL,
 name VARCHAR(255) NOT NULL,
 pid INTEGER NULL,
 path VARCHAR(255) NULL,
PRIMARY KEY (alert_ident,parent_type,parent_ident) 
);

# 5.2.7.3
DROP TABLE IF EXISTS Prelude_ProcessArg;
CREATE TABLE Prelude_ProcessArg (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # A=Analyser T=Target S=Source
 parent_ident INT(8) NOT NULL,
 arg VARCHAR(255) NULL, # size problem ?
INDEX (alert_ident,parent_type,parent_ident)
);

# 5.2.7.3
DROP TABLE IF EXISTS Prelude_ProcessEnv;
CREATE TABLE Prelude_ProcessEnv (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # A=Analyser T=Target S=Source
 parent_ident INT(8) NOT NULL,
 env VARCHAR(255) NULL, # size problem ?
INDEX (alert_ident,parent_type,parent_ident)
);

# 5.2.7.4
DROP TABLE IF EXISTS Prelude_Service;
CREATE TABLE Prelude_Service (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # T=Target S=Source
 parent_ident INT(8) NOT NULL,
 name VARCHAR(255) NULL,
 port INTEGER NULL,
 protocol VARCHAR(255) NULL,
PRIMARY KEY (alert_ident,parent_type,parent_ident),
INDEX (port),
INDEX (protocol),
INDEx (protocol,port)
);

# 5.2.7.4 
# Addon to manipulate portlist easily with SQL request for correlation 
DROP TABLE IF EXISTS Prelude_ServicePortlist;
CREATE TABLE Prelude_ServicePortlist (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # T=Target S=Source
 parent_ident INT(8) NOT NULL,
 portlist VARCHAR(255),
INDEX (alert_ident,parent_type,parent_ident)
);

# 5.2.7.4.1 
DROP TABLE IF EXISTS Prelude_WebService;
CREATE TABLE Prelude_WebService (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # T=Target S=Source
 parent_ident INT(8) NOT NULL,
 url VARCHAR(255) NOT NULL, # size problem ?
 cgi VARCHAR(255) NULL,
 http_method VARCHAR(255) NULL,	# CHANGED FROM method TO http-method IN THE IDMEF v6 (written http"_"method here, problems with "-" symbol)
 				# only PUT or GET : could we improve size ?
PRIMARY KEY (alert_ident,parent_type,parent_ident)
);

# 5.2.7.4.1
DROP TABLE IF EXISTS Prelude_WebServiceArg;
CREATE TABLE Prelude_WebServiceArg (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # A=Analyser T=Target S=Source
 parent_ident INT(8) NOT NULL,
 arg VARCHAR(255) NULL, # size problem ?
INDEX (alert_ident,parent_type,parent_ident)
);

# 5.2.7.4.2
DROP TABLE IF EXISTS Prelude_SNMPService;
CREATE TABLE Prelude_SNMPService (
 alert_ident INT(8) NOT NULL,
 parent_type VARCHAR(1) NOT NULL, # A=Analyser T=Target S=Source
 parent_ident INT(8) NOT NULL,
 oid VARCHAR(255) NULL,
 community VARCHAR(255) NULL,
 command VARCHAR(255) NULL,
PRIMARY KEY (alert_ident,parent_type,parent_ident)
);

###

