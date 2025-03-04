class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else   
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(arr)
        self.new(id: arr[0], name: arr[1], breed: arr[2])
    end

    def self.all
        sql = "SELECT * FROM dogs;"
        DB[:conn].execute(sql).map { |arr| self.new_from_db(arr) }
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE dogs.name = ? LIMIT 1;"
        self.new_from_db(DB[:conn].execute(sql, name).first)
    end

    def self.find(id)
        sql = "SELECT * FROM dogs WHERE dogs.id = ? LIMIT 1;"
        self.new_from_db(DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE dogs.name = ?
        AND dogs.breed = ?
        LIMIT 1;
        SQL

        search = DB[:conn].execute(sql, name, breed).first
        search ? self.new_from_db(search) : self.create(name: name, breed: breed)
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end









