use pracmongo

mongorestore --collection aficiones --db pracmongo C:\hlocal\prac-MongoDB-18-19-CV\dump-para-empezar-prac\aficiones.bson

db.aficiones.count();

db.aficiones.findOne();

db.aficiones.insert({
            "Tema": "Animales",
            "Apodo": "Cat",
            "Nombre": "Atusar gatitos",
            "Puntuacion": 9.5,
            "Precio": 40.5,
            "CantidadGatos": 32,
            "MarcaComida": "CatF"
        });
        
// mongoimport --db pracmongo --collection aficiones --drop --file "file"
        
db.aficiones.find( {"Tema": "Animales"} );

db.aficiones.find( {"Apodo": "Ani"} );

db.aficiones.find({"Precio":{$gte:10}},{_id:0});

db.aficiones.find({"Precio":{$lt:60}},{_id:0});

db.aficiones.find({"Precio":{$gte:10}},{_id:0, Puntuacion:0, Precio:0});

// Minimo de precio

db.aficiones.find().sort({"Precio":1}).limit(1);

db.aficiones.find().sort({"Precio":-1}).limit(1);

// APARTADO 3

db.aficiones.find({Puntuacion:{$gte:9}},{_id:0});

db.aficiones.find({Puntuacion:{$gte:9}},{_id:0});
