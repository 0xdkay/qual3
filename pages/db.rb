require 'sqlite3'
require 'digest/sha1'

class DB
	def initialize
		@db_name = "qual3.db"
		@db = SQLite3::Database.new(@db_name)
		@user_table = "QUAL_USER_TBL"
		@prob_table = "QUAL_PROB_TBL"
		@score_table = "QUAL_SCORE_TBL"
		@notice_table = "QUAL_NOTICE_TBL"

		@db.execute "
		CREATE TABLE IF NOT EXISTS '#{@user_table}' (
			'id' varchar(50) NOT NULL DEFAULT '',
			'pw' varchar(50) DEFAULT NULL,
			'name' varchar(50) DEFAULT NULL,
			'sno' varchar(50) DEFAULT NULL,
			'mail' varchar(50) DEFAULT NULL,
			'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
			'ldate' timestamp NULL DEFAULT NULL,
			'ip' varchar(50) DEFAULT NULL,
			'lip' varchar(50) DEFAULT NULL,
			PRIMARY KEY ('id')
		)
		"

		@db.execute "
		CREATE TABLE IF NOT EXISTS '#{@prob_table}' (
			'category' varchar(50) DEFAULT NULL,
			'title' varchar(50) DEFAULT NULL,
			'author' varchar(50) DEFAULT NULL,
			'body' text,
			'auth' varchar(50) DEFAULT NULL,
			'score' integer DEFAULT NULL,
			'file' varchar(50) DEFAULT NULL,
			'date' timestamp NULL DEFAULT CURRENT_TIMESTAMP,
			'ldate' timestamp DEFAULT NULL,
			PRIMARY KEY ('title')
		)
		"

		@db.execute "
			CREATE TABLE IF NOT EXISTS '#{@notice_table}' (
				'no' integer AUTO_INCREMENT,
				'title' varchar(50) DEFAULT NULL,
				'author' varchar(50) DEFAULT NULL,
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

	def insert_user args
		return false if not @db.execute("SELECT id FROM #{@user_table} WHERE id=:id",
																		"id" => args[:id]).empty?

		true if @db.execute("INSERT INTO #{@user_table} (id, pw, name, sno, mail, date, ip)
									SELECT :id, :pw, :name, :sno, :mail, :date, :ip
								WHERE NOT EXISTS (SELECT id FROM #{@user_table} WHERE id=:id);",
								"id" => args[:id],
								"pw" => Digest::SHA1.hexdigest(args[:pw]),
								"name" => args[:name],
								"sno" => args[:sno],
								"mail" => args[:mail],
								"date" => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
								"ip" => args[:ip])
	end

	def insert_prob args
		return false if not @db.execute("SELECT title FROM #{@prob_table} WHERE title=:title",
																		"title" => args[:title]).empty?
		true if @db.execute("INSERT INTO #{@prob_table} (category, title, author, body, auth, score, file, date)
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
		return false if @db.execute("SELECT id FROM #{@user_table} WHERE id=:id AND pw=:pw",
								"id" => args[:id],
								"pw" => Digest::SHA1.hexdigest(args[:pw])).empty?
		true
	end
end




