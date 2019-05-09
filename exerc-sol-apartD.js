Consulta 1:
Agrupa todos los elementos que tengan una puntuacion mayor de 5 y la calidad sea superior a un 60, agrupado por el genero. Mostrar el nombre y paginas.
No queremos ver el id.

db.aficiones.aggregate([
    {$match: { $and:[ Puntuacion: {$gte:5}, Calidad: {$gte:60}] }},
    {$group: {_id: "$Genero", Nombres: {$push:"Nombres"}, Paginas: {$push:"$Paginas"}}},
    {$project : {_id:0}}
])

Consulta 2:
Mostra el numero de paginas que tendria que leerme agrupado por genero si quiero leerme los libros que tengan una puntuacion superior a 7.

db.aficiones.aggregate([
    {$match: { Puntuacion: {$gte:7} }},
    {$group: {_id: "$Genero", NumPaginas: {$sum:1}}},
    {$project : {_id:0}}
])

Consulta 3:
Me gusta mucho un autor determinado y me gustaria saber cuanto me costaria comprar todos los libros de dicho autor. Agrupado por autor. Queremos
ver el nombre de los libros de dicho autor.

db.aficiones.aggregate([
    {$group: {_id: "$autor", NumPaginas: {$sum:1}, Nombres: {$push:"Nombres"}}},
    {$project : {_id:0}}
])

Consulta 4:
Me gustaria agrupar el precio de todos los jugadores que son de nacionalidad española que sean futbolistas. Interesante mostrar el nombre de estos jugadores.
db.aficiones.aggregate([
    {$match: { $and:[ Tema: "Fútbol", Caracteristicas.Nacionalidad: "Español"},
    {$group: {_id: "$autor", NumPaginas: {$sum:1}, Nombres: {$push:"Nombres"}}},
    {$project : {_id:0}}
])