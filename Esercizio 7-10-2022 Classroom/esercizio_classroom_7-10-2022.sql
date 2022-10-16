/**
 * Francesco Di Lena
 * Classe 5F A.S. 2022-2023
 * 07-10-2022
 * Esercizio di classroom (7-10-2022) sulla creazione e popolamento di un database a partire da una tabella di Excel esistente.
 */

--Creo il database
CREATE DATABASE classroom_exercise_7_10_2022;

USE classroom_exercise_7_10_2022;

--Creo la tabella dentro cui inserirò i dati letti dal CSV
CREATE TABLE report(
data_voto date NOT NULL,
n_matricola int NOT NULL,
nome nvarchar(30) NOT NULL,
cognome nvarchar(30) NOT NULL,
materia nvarchar(30) NOT NULL,
voto decimal(10,2) NOT NULL,
nome_docente nvarchar(30) NOT NULL,
cognome_docente nvarchar(30) NOT NULL,
classe int NOT NULL,
sezione char NOT NULL,
note nvarchar(200)
);

--La seguuente istruzione elimina il contenuto presente all'interno della tabella report.

TRUNCATE TABLE report;

--La seguente istruzione permette di importare le informazioni dal file CSV e inserirle all'interno della tabella report.

BULK INSERT report
FROM 'D:\Scuola\Secondaria di Secondo Grado\V F A.S. 2022-2023\Informatica\Esercizio 7-10-2022 Classroom\elenco_voti.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
);

--Creo questa tabella per potervi inseririre gli studenti

CREATE TABLE student(
registration_number int PRIMARY KEY, --registration_number = numero di matricola
name nvarchar(30) NOT NULL,
surname nvarchar(30) NOT NULL
);

--Popolo la tabella students

INSERT INTO student(registration_number, name, surname)
SELECT DISTINCT n_matricola, nome, cognome
FROM report ;

SELECT * FROM student;

--Creo questa tabella per potervi inseririre gli insegnanti

CREATE TABLE teacher(
id int IDENTITY(1,1) PRIMARY KEY,
name nvarchar(30) NOT NULL,
surname nvarchar(30) NOT NULL
);

INSERT INTO teacher(name, surname)
SELECT DISTINCT nome_docente, cognome_docente
FROM report;

SELECT * FROM teacher;

--Creo questa tabella per potervi inseririre le classi

CREATE TABLE class(
id int IDENTITY(1,1) PRIMARY KEY,
class_number int NOT NULL,
class_section char NOT NULL
);

INSERT INTO class(class_number, class_section)
SELECT DISTINCT classe, sezione
FROM report;

SELECT * FROM class;

--Creo questa tabella per potervi inserire le materie

CREATE TABLE subject(
id int IDENTITY(1,1) PRIMARY KEY,
subject_name nvarchar(80) NOT NULL UNIQUE
);

INSERT INTO subject(subject_name)
SELECT DISTINCT materia
FROM report;

SELECT * FROM subject;

--Creo questa tabella per potervi inseririre i voti presi dagli studenti

CREATE TABLE mark(
mark_id int IDENTITY(1,1) PRIMARY KEY,
mark decimal(10,2) NOT NULL,
notes nvarchar(200),
student_id int NOT NULL,
subject_id int NOT NULL,
teacher_id int NOT NULL,
class_id int NOT NULL
);

--Popolo la tabella mark eseguendo la left join con le tabelle student, subject, teacher e class, in modo che mark possa essere in relazione con esse

INSERT INTO mark(mark, notes,student_id, subject_id , teacher_id, class_id)
SELECT r.voto, r.note, st.registration_number, su.id, t.id, c.id
FROM report r
LEFT JOIN student st ON st.name = r.nome AND st.surname = r.cognome AND st.registration_number =r.n_matricola 
LEFT JOIN subject su ON su.subject_name=r.materia
LEFT JOIN teacher t ON t.name=r.nome_docente AND t.surname=r.cognome_docente 
LEFT JOIN class c ON c.class_number = r.classe AND c.class_section =r.sezione;

SELECT * FROM mark;