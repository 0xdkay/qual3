require 'sqlite3'
require 'digest/sha1'

class DB
    def initialize db_name
        @db_name = db_name
        @db = SQLite3::Database.new(@db_name)
        @user_table = "QUAL_USER_TBL"
        @prob_table = "QUAL_PROB_TBL"
        @score_table = "QUAL_SCORE_TBL"
        @notice_table = "QUAL_NOTICE_TBL"

        @db.execute "
        CREATE TABLE IF NOT EXISTS '#{@user_table}' (
            'id' varchar(50) NOT NULL,
            'pw' varchar(50) NOT NULL,
            'name' varchar(50) NOT NULL,
            'sno' varchar(50) NOT NULL,
            'mail' varchar(50) NOT NULL,
            'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
            'ldate' timestamp DEFAULT NULL,
            'ip' varchar(50) NOT NULL,
            'lip' varchar(50) DEFAULT NULL,
            'token' varchar(50) DEFAULT NULL,
            PRIMARY KEY ('id')
        )
        "

        @db.execute "
        CREATE TABLE IF NOT EXISTS '#{@prob_table}' (
            'category' varchar(50) NOT NULL,
            'title' varchar(50) NOT NULL,
            'author' varchar(50) NOT NULL,
            'body' text,
            'auth' varchar(50) NOT NULL,
            'score' integer NOT NULL,
            'file' varchar(50) DEFAULT NULL,
            'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
            'ldate' timestamp DEFAULT NULL,
            PRIMARY KEY ('title')
        )
        "

        @db.execute "
            CREATE TABLE IF NOT EXISTS '#{@notice_table}' (
                'no' integer AUTO_INCREMENT,
                'title' varchar(50) NOT NULL,
                'author' varchar(50) NOT NULL,
                'body' text,
                'file' varchar(50) DEFAULT NULL,
                'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                'ldate' timestamp DEFAULT NULL,
                PRIMARY KEY ('no')
            )
        "

        @db.execute "
        CREATE TABLE IF NOT EXISTS '#{@score_table}' (
            'title' integer NOT NULL,
            'id' varchar(50) NOT NULL,
            'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY ('title','id')
        )
        "

        @db.execute "
        CREATE TRIGGER IF NOT EXISTS Update_Last_Login
        AFTER UPDATE
        ON #{@user_table}
        FOR EACH ROW
        BEGIN
        UPDATE #{@user_table} SET ldate = CURRENT_TIMESTAMP WHERE id=old.id;
        END
        "

        @db.execute "
        CREATE TRIGGER IF NOT EXISTS Update_Last_Modify_Prob
        AFTER UPDATE
        ON #{@prob_table}
        FOR EACH ROW
        BEGIN
        UPDATE #{@prob_table} SET ldate = CURRENT_TIMESTAMP WHERE title=old.title;
        END
        "

        @db.execute "
        CREATE TRIGGER IF NOT EXISTS Update_Last_Modify_Notice
        AFTER UPDATE
        ON #{@notice_table}
        FOR EACH ROW
        BEGIN
        UPDATE #{@notice_table} SET ldate = CURRENT_TIMESTAMP WHERE no=old.no;
        END
        "


        @db.execute "
        CREATE TRIGGER IF NOT EXISTS Update_Last_Auth
        AFTER UPDATE
        ON #{@score_table}
        FOR EACH ROW
        BEGIN
        UPDATE #{@score_table} SET date = CURRENT_TIMESTAMP WHERE title=old.title and id=old.id;
        END
        "

    end


    protected
    def encrypt data
        Digest::SHA1.hexdigest(data+$secret)
    end

    def check_params check, input
        check.each do |v|
            if not input[v]
                return false
            end
        end
        return true
    end

    def new_token mail
        token = encrypt(mail+Time.now.utc.to_s)
    end

    public

    def insert_user args
        check_args = [:id, :pw, :name, :sno, :mail, :ip]
        return -1 if not check_params check_args, args
        return 0 if not @db.execute("SELECT id FROM #{@user_table} WHERE id=:id or mail=:mail",
                                                                        "id" => args[:id],
                                                                        "mail" => args[:mail]).empty?

        return 1 if @db.execute("INSERT INTO #{@user_table} (id, pw, name, sno, mail, date, ip)
                                    SELECT :id, :pw, :name, :sno, :mail, :date, :ip
                                WHERE NOT EXISTS (SELECT id FROM #{@user_table} WHERE id=:id);",
                                "id" => args[:id],
                                "pw" => encrypt(args[:pw]),
                                "name" => args[:name],
                                "sno" => args[:sno],
                                "mail" => args[:mail],
                                "date" => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                                "ip" => args[:ip])
    end

    def insert_prob args
        check_args = [:category, :title, :author, :body, :auth, :score]
        return -1 if not check_params check_args, args
        return 0 if not @db.execute("SELECT title FROM #{@prob_table} WHERE title=:title",
                                                                        "title" => args[:title]).empty?
        return 1 if @db.execute("INSERT INTO #{@prob_table} (category, title, author, body, auth, score, file, date)
                                    SELECT :category, :title, :author, :body, :auth, :score, :file, :date
                                WHERE NOT EXISTS (SELECT title FROM #{@prob_table} WHERE title=:title);",
                                "category" => args[:category],
                                "title" => args[:title],
                                "author" => args[:author],
                                "body" => args[:body],
                                "auth" => args[:auth],
                                "score" => args[:score],
                                "file" => args[:file],
                                "date" => Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    end

    def check_login args
        check_args = [:id, :pw, :ip]
        return -1 if not check_params check_args, args
        return 0 if @db.execute("SELECT id FROM #{@user_table} WHERE id=:id AND pw=:pw",
                                "id" => args[:id],
                                "pw" => encrypt(args[:pw])).empty?
        @db.execute("UPDATE #{@user_table} SET lip=:ip WHERE id=:id",
                                "ip" => args[:ip])
        return 1
    end

    def check_mail args
        check_args = [:mail]
        return -1 if not check_params check_args, args
        return 0 if @db.execute("SELECT mail FROM #{@user_table} WHERE mail=:mail",
                                                                "mail" => args[:mail]).empty?
        token = new_token args[:mail]
        @db.execute("UPDATE #{@user_table} SET token=:token WHERE mail=:mail",
                                "mail" => args[:mail],
                                "token" => token)
        return token
    end

    def check_token args
        check_args = [:token]
        return -1 if not check_params check_args, args
        p @db.execute("SELECT token FROM #{@user_table} WHERE token=:token",
                                    "token" => args[:token])
        return 0 if @db.execute("SELECT mail FROM #{@user_table} WHERE token=:token",
                                                        "token" => args[:token]).empty?
        return 1
    end
    
    def reset_password args
        check_args = [:token, :pw]
        return -1 if not check_params check_args, args
        p args
        p args[:token]
        p @db.execute("SELECT token FROM #{@user_table}")
        p @db.execute("SELECT token FROM #{@user_table} WHERE token=:token",
                                 "token" => args[:token])
        @db.execute("UPDATE #{@user_table} SET pw=:pw and token=NULL WHERE token=:token",
                                "pw" => args[:pw],
                                "token" => args[:token].strip)
        return 1
    end
end


