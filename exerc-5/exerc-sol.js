// Configuracion inicial de la base de datos
// lanzar en Entorno Mongo
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
// Apartado a 
// Consulta 1
db.aficiones.find({Puntuacion:{$gte:9}},{_id:0});

// Consulta 2
db.aficiones.aggregate([

    { $match: {Puntuacion: {$gte:9}}},

    {$group: {_id: "$Tema", PrecioTotal:{$sum:"$Precio"}, NumDocumentos :{$sum:1}}} 

    ]);

// Comprobacion de la query
db.aficiones.find( {$and:[ {"Tema": "Rugby"}, {Puntuacion:{$gte:9}} ] });

// Consulta 3
db.aficiones.aggregate([

    { $match: { Puntuacion: {$in: [10,9,8,7,6,5]}}},

    {$group: {_id: "$Puntuacion", Nombres: {$push:"$Nombre"}, Temas: {$push:"$Tema"}}},

    {$project : {_id:0} }

 ]);


// Consulta 4
db.aficiones.aggregate([

    {$group: {_id: "$Tema", Apodos: {$push:"$Apodo"}}}

    ]);
    

// Apartado b 
var x = db.aficiones.aggregate([

    {$group: {_id: "$Tema", Apodos: {$push:"$Apodo"}, Nombres: {$push:"$Nombre"} }}

    ]);

// Apartado d 
//
//

// Consulta 1:
// Muestra todos los elementos que tengan una puntuacion mayor de 5 y la calidad sea superior a un 60, agrupado por el genero. Mostrar solo el nombre y paginas.
// No queremos ver el id.

db.aficiones.aggregate([
    {$match: { $and:[ Puntuacion: {$gte:5}, Calidad: {$gte:60}] }},
    {$group: {_id: "$Genero", Nombres: {$push:"Nombres"}, Paginas: {$push:"$Paginas"}}},
    {$project : {_id:0}}
]);

// Consulta 2:
// Muestra el numero de paginas que tendria que leerme agrupado por genero si quiero leerme
//  los libros que tengan una puntuacion superior a 7.

db.aficiones.aggregate([
    {$match: { Puntuacion: {$gte:7} }},
    {$group: {_id: "$Genero", NumPaginas: {$sum:1}}},
    {$project : {_id:0}}
]);

// Consulta 3:
// Muestra el precio que deberia pagar para comprar todos los libros de cada uno de los autores.

db.aficiones.aggregate([
    {$group: {_id: "$autor", PrecioTotalLibrosAutor: {$sum:1}}}
]);

// Consulta 4:
// Mostrar el nombre de todos los futbolistas agrupando por nacionalidad.

db.aficiones.aggregate([
    {$match: { Tema: "Fútbol"},
    {$group: {_id: "$Caracteristicas.Nacionalidad", Nombres: {$push:"Nombres"}}}
]);
    
// Apartado e
//
// Tantop find() como aggregate() devuelven un cursor
db.aficiones.aggregate([
    {$group: {_id:"$Tema"}}
]).forEach(element => {
    print("Tema: " + element.Tema + " Apodo: " + element.Apodo +
     " Nombre: "+ element.Nombre + " Puntuacion: " +  element.Puntuacion);
});

// Apartado f
//
db.aficiones.update(
    {Puntuacion:{$lt:7}},
    { $set: { Precio: Precio*0.9, Descuento: Precio*0.1} },
    { multi: true }
)

// Apartado g
//
db.createCollection("PorNivel");
// Insertamos la estructura de los documentos
db.PorNivel.insert(
    {
        "NomCal": "intervalo1",
        "Componentes": []
    },
    {
        "NomCal": "intervalo2",
        "Componentes": []
    },
    {
        "NomCal": "intervalo3",
        "Componentes": []
    },
    {
        "NomCal": "intervalo4",
        "Componentes": []
    }
)
// Funcion que calcula el nivel de calidad de un elemento
function nivelCalidad(puntuacion, precio){
    return Math.round((puntuacion * precio) / 100);
}
// Insertamos en la coleccion "PorNivel" todos los 
// documentos de la coleccion "aficiones" de manera apropiada
db.aficiones.find().forEach(element => {
    var nivCal = nivelCalidad(element.Puntuacion, element.Precio);
    var nomCal = "";
    if (nivCal < 25){
        nomCal = "intervalo1";
    }
    else if (nivCal < 50){
        nomCal = "intervalo2";
    }
    else if (nivCal < 75){
        nomCal = "intervalo3";
    }
    else{
        nomCal = "intervalo4";
    }
    db.PorNivel.update(
        { NombreCal: nomCal },
        { $push: { Componentes: { Comp: element, Cal: nivCal}}}
    );
});

db.PorNivel.find();

db.PorNivel.find({}, {_id:0, NomCal:1, Componentes.Comp.Precio:1, Componentes.Comp.Nombre:1}).sort({"Componentes.Comp.Precio":1});

// Apartado 4
//
db.createCollection("SuperGuai");
// Inserta los 5 elementos de la coleccion "aficiones" que tienen el nivel de calidad
// mas alto
db.SuperGuai.insert(
    db.aficiones.find().sort({ nivelCalidad(Puntuacion, Precio): -1}).limit(5);
);

// Apartado 5
//
// Se trata de una base de datos que contiene alimentos
db.createCollection("apartado5");
db.apartado5.insert( 
    {
        "Nombre": "Galletas",
        "Supermercado": "Mercadona",
        "Precio": 30,
        "%Leche": 10,
        "%Azucar": 15,
        "%Canela": 30
    },
    {
        "Nombre": "Cereales",
        "Supermercado": "Carrefour",
        "Precio": 30,
        "%Trigo": 10,
        "%Edulcorante": 15,
        "%Chocolate": 30
    }
)
// 5.Extra
// - Conviene desnormalizar ya que asi en una sola consulta obtendriamos todas las propiedades del objeto en cuestion
//      ganando en eficiencia.

// Apartado 6
//
// Apartado B
db.aficiones.find(
    {
        Nombre: "MotoGP"
    }
).forEach(function(element) {
    db.collection.update(
        { "_id": element._id }, 
        { "$set": { "Nombre": element.NombreEquipo, "Puntuacion": element.Puntuacón, "Precio":100 }, "$unset": { "NombreEquipo":1, "Puntuacón":1} }
    );
});
db.aficiones.find(
    {
        Nombre: "Ajedrez"
    }
).forEach(function(element) {
    db.collection.update(
        { "_id": element._id }, 
        { "$set": { "Nombre": element.Nombre + element.Apellidos, "Precio":100 }, "$unset": { "Apellidos":1} }
    );
});
// Apartado C
db.createCollection( "animales",
   { validator: { $and:
      [
         { Tema: { $type: "string", "$exists": true } },
         { Apodo: { $type: "string", "$exists": true } },
         { Nombre: {$type: "string", "$exists": true } },
         { Precio: {$type: "double", "$exists": true } },
         { Tipo: {$type: "string", $in: [ "Mamifero", "Reptil", "Pez", "Ave", "Anfibios", "Invertebrado" ] } }
       ] } 
    }
   );
db.animales.insert( // Debe ser aceptado
{
    "Tema" : "Animales",
    "Apodo" : "Gato",
    "Nombre" : "Miau",
    "Precio": 8.5,
    "Tipo": "Mamifero"
}
);
db.animales.insert( // Debe ser rechazado
{
    "Tema" : "Animales",
    "Apodo" : "Gato",
    "Nombre" : "Miau",
    "Tipo": "Mamifero"
}
);

// Apartado D
db.createCollection("solodatos");
db.createCollection("soloaficiones");
db.aficiones.find().forEach(element => {
    // esto da todas las claves del documento element -> for (key in element) print(key);
    db.solodatos.insert(
        {
            _id: element._id
            
        }
    );
    db.soloaficiones.insert(
        {
            _id: element._id,
            Tema: element.Tema,
            Nombre: element.Nombre,
            Apodo: element.Apodo,
            Precio: element.Precio
        }
    );
});

// Apartado E
db.solodatos.find().array.forEach(element => {
    var x = db.soloaficiones.findOne( { "_id": element._id });
    print(element)
    print(x)
});

// Apartado F
db.solodatos.aggregate([
    {
      $lookup:
        {
          from: "soloaficiones",
          localField: "_id",
          foreignField: "_id",
          as: "detalles"
        }
   }
 ])