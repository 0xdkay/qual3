# -*- encoding : utf-8 -*-
require 'sqlite3'
require 'digest/sha1'
require 'fileutils'

class DB
    def initialize db_name
        @db_name = db_name
        @db = SQLite3::Database.new(@db_name)
        @user_table = "QUAL_USER_TBL"
        @prob_table = "QUAL_PROB_TBL"
        @score_table = "QUAL_SCORE_TBL"
        @notice_table = "QUAL_NOTICE_TBL"
        @secret = YAML.load_file("config.yml")["token_key"].to_s

        @db.execute "PRAGMA encoding = 'UTF-8';"

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
            'pno' integer PRIMARY KEY AUTOINCREMENT,
            'category' varchar(50) NOT NULL,
            'title' varchar(50) NOT NULL,
            'author' varchar(50) NOT NULL,
            'body' text,
            'auth' varchar(50) NOT NULL,
            'score' integer NOT NULL,
            'file' varchar(50) DEFAULT NULL,
            'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
            'ldate' timestamp DEFAULT NULL
        )
        "

        @db.execute "
            CREATE TABLE IF NOT EXISTS '#{@notice_table}' (
                'no' integer PRIMARY KEY AUTOINCREMENT,
                'title' varchar(50) NOT NULL,
                'author' varchar(50) NOT NULL,
                'body' text,
                'file' varchar(50) DEFAULT NULL,
                'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                'ldate' timestamp DEFAULT NULL
            )
        "

        @db.execute "
        CREATE TABLE IF NOT EXISTS '#{@score_table}' (
            'pno' integer NOT NULL,
            'id' varchar(50) NOT NULL,
            'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY ('pno','id')
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
        UPDATE #{@prob_table} SET ldate = CURRENT_TIMESTAMP WHERE pno=old.pno;
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
        UPDATE #{@score_table} SET date = CURRENT_TIMESTAMP WHERE pno=old.pno and id=old.id;
        END
        "

    end


    protected
    def encrypt data
        Digest::SHA1.hexdigest(data+@secret)
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
        encrypt(mail+Time.now.utc.to_s).force_encoding("UTF-8")
    end

    def get_date 
        Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end

    def create_file args, hash=true
        if args[:file][:tempfile] and args[:file][:filename]
            args[:file][:filename] = encrypt(args[:file][:filename]) if hash
            File.open('uploads/' + args[:category] + "/" + args[:file][:filename], "w") do |f|
                f.write(args['file'][:tempfile].read)
            end
        end
    end

    def delete_file res
        File.delete("uploads/#{res[1]}/#{res[2]}") if not res[2].empty?
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
                                "date" => get_date,
                                "ip" => args[:ip])
    end

    def insert_prob args
        check_args = [:category, :title, :author, :body, :auth, :score]
        return -1 if not check_params check_args, args
        if args[:file]
            create_file args
            file = args[:file][:filename]
        else
            file = ""
        end
        return 1 if @db.execute("INSERT INTO #{@prob_table} (category, title, author, body, auth, score, file, date)
                                    VALUES (:category, :title, :author, :body, :auth, :score, :file, :date)",
                                "category" => args[:category],
                                "title" => args[:title],
                                "author" => args[:author],
                                "body" => args[:body],
                                "auth" => args[:auth],
                                "score" => args[:score],
                                "file" => file,
                                "date" => get_date)
    end

    def modify_prob args
        check_args = [:pno, :category, :title, :author, :body, :auth, :score]
        return -1 if not check_params check_args, args
        res = @db.execute("SELECT pno, category, file FROM #{@prob_table} WHERE pno=:pno",
                                         "pno" => args[:pno])[0]
        return 0 if not res
        if args[:file]
            args[:file][:filename] = encrypt(args[:file][:filename])
            if args[:file][:filename] != res[2]
                delete_file res
                create_file args, false
            end
            file = args[:file][:filename]
        else
            file = ""
        end
        return 1 if @db.execute("UPDATE #{@prob_table} 
                                                        SET category=:category, title=:title, author=:author, 
                                                                body=:body, auth=:auth, score=:score, file=:file
                                                        WHERE pno=:pno",
                                                        "pno" => args[:pno],
                                                        "category" => args[:category],
                                                        "title" => args[:title],
                                                        "author" => args[:author],
                                                        "body" => args[:body],
                                                        "auth" => args[:auth],
                                                        "score" => args[:score],
                                                        "file" => file)
    end

    def delete_prob args
        check_args = [:pno]
        return -1 if not check_params check_args, args
        res = @db.execute("SELECT pno, category, file FROM #{@prob_table} WHERE pno=:pno",
                                            "pno" => args[:pno])[0]
        return 0 if res.empty?
        delete_file res
        return 1 if @db.execute("DELETE FROM #{@prob_table} WHERE pno=:pno",
                                                     "pno" => args[:pno])
    end

    def probfile_delete args
        check_args = [:pno]
        return -1 if not check_params check_args, args
        res = @db.execute("SELECT pno, category, file FROM #{@prob_table} WHERE pno=:pno",
                                            "pno" => args[:pno])[0]
        return 0 if res.empty? or res[2].empty?
        delete_file res
        return 1 if @db.execute("UPDATE #{@prob_table} SET file='' WHERE pno=:pno",
                                                        "pno" => args[:pno])
    end

    def check_login args
        check_args = [:id, :pw, :ip]
        return -1 if not check_params check_args, args
        return 0 if @db.execute("SELECT id FROM #{@user_table} WHERE id=:id AND pw=:pw",
                                "id" => args[:id],
                                "pw" => encrypt(args[:pw])).empty?
        @db.execute("UPDATE #{@user_table} SET lip=:ip WHERE id=:id",
                                "ip" => args[:ip],
                                "id" => args[:id])
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
        token = @db.execute("SELECT token FROM #{@user_table}")[0][0]
        return 0 if @db.execute("SELECT mail FROM #{@user_table} WHERE token=:token",
                                                        "token" => args[:token]).empty?
        return 1
    end
    
    def reset_password args
        check_args = [:token, :pw]
        return -1 if not check_params check_args, args
        @db.execute("UPDATE #{@user_table} SET pw=:pw, token='' WHERE token=:token",
                                "pw" => encrypt(args[:pw]),
                                "token" => args[:token])
        return 1
    end

    def get_probs
        @db.execute("SELECT t1.pno, t1.category, t1.score, t2.solved FROM #{@prob_table} t1
                                LEFT JOIN
                                    (SELECT pno, count(*) as solved FROM #{@score_table} GROUP BY pno) t2
                                ON t1.pno = t2.pno
                                ORDER BY t1.score")
    end

    def show_prob args
        check_args = [:pno]
        return -1 if not check_params check_args, args
        @db.execute("SELECT t1.*, t2.solved FROM #{@prob_table} t1
                                LEFT JOIN
                                    (SELECT pno, count(*) as solved FROM #{@score_table} GROUP BY pno) t2
                                ON t1.pno = t2.pno
                                WHERE t1.pno = :pno
                                ORDER BY t1.score",
                             "pno" => args[:pno])[0]
    end

    def check_auth args
        check_args = [:pno, :auth, :id]
        return -1 if not check_params check_args, args
        return 2 if not @db.execute("SELECT pno FROM #{@score_table} WHERE pno=:pno and id=:id",
                                                     "pno" => args[:pno],
                                                     "id" => args[:id]).empty?
        return 0 if @db.execute("SELECT pno FROM #{@prob_table} WHERE pno=:pno and auth=:auth",
                                "pno" => args[:pno],
                                "auth" => args[:auth]).empty?
        @db.execute("INSERT INTO #{@score_table} (pno, id) VALUES (:pno, :id)",
                                 "pno" => args[:pno],
                                 "id" => args[:id])
        return 1
    end

    def insert_notice args
        check_args = [:title, :author, :body]
        return -1 if not check_params check_args, args
        if args[:file]
            args[:category] = "notices"
            create_file args, false
            file = args[:file][:filename]
        else
            file = ""
        end
        return 1 if @db.execute("INSERT INTO #{@notice_table} (title, author, body, file, date)
                                    VALUES (:title, :author, :body, :file, :date)",
                                "title" => args[:title],
                                "author" => args[:author],
                                "body" => args[:body],
                                "file" => file,
                                "date" => get_date)
    end

    def delete_notice args
        check_args = [:no]
        return -1 if not check_params check_args, args
        res = @db.execute("SELECT no, 'notices', file FROM #{@notice_table} WHERE no=:no",
                                            "no" => args[:no])[0]
        return 0 if res.empty?
        delete_file res
        return 1 if @db.execute("DELETE FROM #{@notice_table} WHERE no=:no",
                                                        "no" => args[:no])
    end

    def modify_notice args
        check_args = [:no, :title, :author, :body]
        return -1 if not check_params check_args, args
        res = @db.execute("SELECT no, 'notices', file FROM #{@notice_table} WHERE no=:no",
                                         "no" => args[:no])[0]
        return 0 if not res
        if args[:file]
            args[:category] = "notices"
            if args[:file][:filename] != res[2]
                delete_file res
                create_file args, false
            end
            file = args[:file][:filename]
        else
            file = ""
        end
        return 1 if @db.execute("UPDATE #{@notice_table} 
                                                        SET title=:title, author=:author, 
                                                                body=:body, file=:file
                                                        WHERE no=:no",
                                                        "no" => args[:no],
                                                        "title" => args[:title],
                                                        "author" => args[:author],
                                                        "body" => args[:body],
                                                        "file" => file)
    end

    def noticefile_delete args
        check_args = [:no]
        return -1 if not check_params check_args, args
        res = @db.execute("SELECT no, 'notices', file FROM #{@notice_table} WHERE no=:no",
                                            "no" => args[:no])[0]
        return 0 if res.empty? or res[2].empty?
        delete_file res
        return 1 if @db.execute("UPDATE #{@notice_table} SET file='' WHERE no=:no",
                                                        "no" => args[:no])
    end

    def get_notices
        @db.execute("SELECT * FROM #{@notice_table} order by no desc")
    end

    def get_ranks
        @db.execute("SELECT t3.name, sum(t2.score) as s
                                FROM #{@score_table} t1, #{@prob_table} t2, #{@user_table} t3
                                WHERE t1.pno=t2.pno and t1.id=t3.id GROUP BY t3.name ORDER BY s DESC")
    end
end


