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
// Muestra todos los elementos que tengan una puntuacion mayor de 5 y la calidad sea superior a un 60, agrupado por el genero.
//    Mostrar solo el nombre y paginas. No queremos ver el id.

db.aficiones.aggregate([
    {$match: { $and: [ {Puntuacion: {$gte:5}}, {Calidad: {$gte:60}}] }},
    {$group: {_id: "$Genero", Nombres: {$push:"$Nombre"}, Paginas: {$push:"$Pagina"}}},
    {$project : {_id:0}}
]);

// Consulta 2:
// Muestra el numero de paginas que tendria que leerme agrupado por genero si quiero leerme
//  los libros que tengan una puntuacion superior a 7.

db.aficiones.aggregate([
    {$match: { Puntuacion: {$gte:7} }},
    {$group: {_id: "$genero", NumPaginas: {$sum:"$paginas"}}}
]);
    db.aficiones.find({genero:null});

// Consulta 3:
// Muestra el precio que deberia pagar para comprar todos los libros de cada uno de los autores.

db.aficiones.aggregate([
    {$group: {_id: "$autor", PrecioTotalLibrosAutor: {$sum:1}}}
]);

// Consulta 4:
// Mostrar el nombre de todos los futbolistas agrupando por nacionalidad.

db.aficiones.aggregate([
    {$match: { Tema:"Fútbol"}},
    {$group: { _id: "$Caracteristicas.Nacionalidad", Nombres: {$push:"$Nombre"}}}
]);
    
// Apartado e
//
// Tanto find() como aggregate() devuelven un cursor
db.aficiones.aggregate([
    {$group: {_id:"$Tema", Nombres: {$push:"$Nombre"}, Apodos: {$push:"$Apodo"}, Puntuaciones: {$push:"$Puntuacion"}}}
]).forEach(element => {
    print("Tema: " + element._id + "\n" + "  Apodo: " + element.Apodos + "\n" +
     "  Nombre: "+ element.Nombres + "\n" + "  Puntuacion: " +  element.Puntuaciones);
});

// Apartado f
//
db.aficiones.find(
    {Puntuacion:{$lt:7}}
).forEach(element => {
    db.aficiones.update(
    {_id: element._id},
    { $set: { Precio: element.Precio*0.9, Descuento: element.Precio*0.1} },
    { multi: true }
)
});

// Apartado g
//
db.PorNivel.drop(); // Por si existiera de pruebas anteriores
db.createCollection("PorNivel");
// Insertamos la estructura de los documentos
db.PorNivel.insertMany([
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
]);
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
        { NomCal: nomCal },
        { $push: { Componentes: { Comp: element, Cal: nivCal}}}
    );
});

db.PorNivel.find();

db.PorNivel.find(
    {},
    {_id:0, NomCal:1, "Componentes.Comp.Precio":1, "Componentes.Comp.Nombre":1}
).sort({"Componentes.Comp.Precio":1});

// Apartado 4
//
db.createCollection("SuperGuai");
// Inserta los 5 elementos de la coleccion "aficiones" que tienen el nivel de calidad
// mas alto
db.SuperGuai.insertMany(
    db.aficiones.find().sort({ nivelCalidad(Puntuacion, Precio): -1}).limit(5);
);
    
db.aficiones.find().forEach(element => {
     db.aficiones.find().sort({ nivelCalidad(element.Puntuacion, element.Precio): -1}).limit(5);
});

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
);
db.apartado5.find();
// 5.Extra
// - Conviene desnormalizar ya que asi en una sola consulta obtendriamos todas las propiedades del objeto en cuestion
//      ganando en eficiencia.

// Apartado 6
//
// Apartado B
db.aficiones.find(
    {
        Tema: "MotoGP"
    }
).forEach(function(element) {
    db.collection.update(
        { "_id": element._id }, 
        { "$set":
            { "Nombre": element.NombreEquipo, "Puntuacion": element.Puntuacón, "Precio":100 },
         "$unset": { "NombreEquipo":1, "Puntuacón":1}
        },
        false, // upsert
        true // multi
    );
    print(element);
});
db.aficiones.find({ Tema: "MotoGP"});
db.aficiones.find(
         { Tema:{$in:["Fútbol", "Baloncesto"]}}
).forEach(function(element) {
    var nuevoPrecio = 0;
    if(element.Precio > 1000){
            nuevoPrecio = element.Precio / 10;
        }
    db.collection.update(
        { "_id": element._id }, 
        { "$set": { "Precio": nuevoPrecio} }
    );
});
db.aficiones.find(
    {
        Tema: "Ajedrez"
    }
).forEach(function(element) {
    db.collection.update(
        { "_id": element._id }, 
        { 
            "$set": { "Nombre": element.Nombre + element.Apellidos, "Precio":100 },
            "$unset": { "Apellidos":""} 
        }
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
            element
        }
    );
});
db.solodatos.find().forEach(element => {
    db.soloaficiones.update(
        {_id: element._id},
        {
            $unset:{
                "element._id": "",
                "element.Tema": "",
                "element.Nombre": "",
                "element.Apodo": "",
                "element.Puntuacion": "",
                "element.Precio": ""
            }
        }
    );
});
db.solodatos.find().forEach(element => {
    db.soloaficiones.insert(
        {
            _id: element._id,
            Tema: element.element.Tema,
            Nombre: element.element.Nombre,
            Apodo: element.element.Apodo,
            Precio: element.element.Precio
        }
);
});
db.soloaficiones.find();
// Apartado E
db.solodatos.find().forEach(element => {
    var x = db.soloaficiones.findOne( { "_id": element._id });
    print(element)
    print(x)
});

// Apartado F
db.soloaficiones.aggregate([
    {
      $lookup:
        {
          from: "solodatos",
          localField: "_id",
          foreignField: "_id",
          as: "detalles"
        }
   }
 ]);