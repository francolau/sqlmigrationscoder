CREATE DATABASE IF NOT EXISTS `redsocial_laurino`;
USE `redsocial_laurino`;

-- TABLA USUARIOS --
CREATE TABLE `users` (
  `userid` int NOT NULL AUTO_INCREMENT,
  `fullname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `occupation` varchar(255) DEFAULT NULL,
  `gender` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`userid`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA POSTS --
CREATE TABLE `posts` (
  `postid` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `date` datetime DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `likes` int DEFAULT '0',
  PRIMARY KEY (`postid`),
  KEY `userid_idx` (`userid`),
  CONSTRAINT `creatorid` FOREIGN KEY (`userid`) REFERENCES `users` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA NOTIFICACIONES --
CREATE TABLE `notifications` (
  `notificationid` int NOT NULL AUTO_INCREMENT,
  `userid` int DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `detail` text,
  `read` tinyint(1) DEFAULT '0',
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`notificationid`),
  KEY `notifyuser_idx` (`userid`),
  CONSTRAINT `notifyuser` FOREIGN KEY (`userid`) REFERENCES `users` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA LIKES--
CREATE TABLE `likes` (
  `likeid` int NOT NULL AUTO_INCREMENT,
  `userid` int DEFAULT NULL,
  `postid` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`likeid`),
  KEY `postid__idx` (`postid`),
  KEY `userid__idx` (`userid`),
  CONSTRAINT `postid_` FOREIGN KEY (`postid`) REFERENCES `posts` (`postid`),
  CONSTRAINT `userid_` FOREIGN KEY (`userid`) REFERENCES `users` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA AMISTADES / CONEXIONES --
CREATE TABLE `friends` (
  `friendsid` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL,
  `userid2` int NOT NULL,
  `state` varchar(45) DEFAULT NULL,
  `friendshipdate` datetime DEFAULT NULL,
  PRIMARY KEY (`friendsid`),
  KEY `userid_idx` (`userid`),
  KEY `userid2_idx` (`userid2`),
  CONSTRAINT `userid` FOREIGN KEY (`userid`) REFERENCES `users` (`userid`),
  CONSTRAINT `userid2` FOREIGN KEY (`userid2`) REFERENCES `users` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- TABLA COMENTARIOS --
CREATE TABLE `comments` (
  `commentid` int NOT NULL AUTO_INCREMENT,
  `userid` int DEFAULT NULL,
  `postid` int DEFAULT NULL,
  `content` text,
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`commentid`),
  KEY `userid__idx` (`userid`),
  KEY `postid__idx` (`postid`),
  CONSTRAINT `commentatorid` FOREIGN KEY (`userid`) REFERENCES `users` (`userid`),
  CONSTRAINT `post` FOREIGN KEY (`postid`) REFERENCES `posts` (`postid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

      -- INSERCION DE DATOS --

    -- EJEMPLOS --

INSERT INTO users (fullname, email, password, date, occupation, gender)
VALUES ('Juan Pérez', 'juan@example.com', 'clave123', '2023-01-01 10:00:00', 'Desarrollador', 'Masculino'),
       ('María García', 'maria@example.com', 'contraseña456', '2023-01-02 11:00:00', 'Diseñadora', 'Femenino'),
       ('Carlos López', 'carlos@example.com', '123456', '2023-01-03 12:00:00', 'Desarrollador', 'Masculino');

INSERT INTO posts (userid, date, content, likes)
VALUES (1, '2023-01-01 13:00:00', 'Este es mi primer post', 10),
       (2, '2023-01-02 14:00:00', '¡Hola mundo!', 20),
       (3, '2023-01-03 15:00:00', 'Estoy aprendiendo SQL', 15);


INSERT INTO notifications (userid, type, detail,`read`, date)
VALUES (1, 'Nuevo seguidor', 'Juan Pérez ahora te sigue', 0, '2023-01-01 14:00:00'),
       (2, 'Nuevo comentario', 'María García ha comentado tu publicación', 0, '2023-01-02 15:00:00'),
       (3, 'Nuevo like', 'Carlos López le ha dado like a tu publicación', 0, '2023-01-03 16:00:00');

INSERT INTO likes (userid, postid, date)
VALUES (2, 1, '2023-01-01 14:00:00'),
       (3, 1, '2023-01-02 15:00:00'),
       (1, 2, '2023-01-03 16:00:00');

INSERT INTO friends (userid, userid2, state, friendshipdate)
VALUES (1, 2, 'Aceptado', '2023-01-01 12:00:00'),
       (1, 3, 'Aceptado', '2023-01-02 13:00:00'),
       (2, 3, 'Aceptado', '2023-01-03 14:00:00');

INSERT INTO comments (userid, postid, content, date)
VALUES (2, 1, '¡Qué buen post!', '2023-01-01 16:00:00'),
       (3, 2, 'Me encanta esta foto', '2023-01-02 17:00:00'),
       (1, 3, '¡Excelente trabajo!', '2023-01-03 18:00:00');


-- TRIGGERS

  -- LIKES
-- CADA VEZ QUE SE GENERA UN LIKE, SOBRE EL POST SE ACTUALIZA EL CAMPO LIKES  
CREATE DEFINER=`root`@`localhost` TRIGGER `likes_BEFORE_INSERT` BEFORE INSERT ON `likes` FOR EACH ROW BEGIN
SET NEW.date = NOW();
  UPDATE posts SET likes = likes + 1 WHERE postid = NEW.postid;
END

-- VERIFICA SI TIENE LIKES EN EL POST
CREATE DEFINER=`root`@`localhost` TRIGGER `hasInserted_BEFORE_INSERT` BEFORE INSERT ON `likes` FOR EACH ROW BEGIN
    DECLARE likes_count INT;
    DECLARE hasLikes BOOLEAN;
    
    SELECT COUNT(*) INTO likes_count FROM likes WHERE userid = NEW.userid and postid = NEW.postid;

    IF likes_count > 0 THEN
        SET hasLikes = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pueden agregar más likes. El usuario ya ha dado like antes';
    ELSE 
        SET hasLikes = FALSE;
    END IF;
END

-- EL POST NO DEBERÍA PODER TENER MAS LIKES QUE USUARIOS EN LA RED SOCIAL
CREATE DEFINER=`root`@`localhost` TRIGGER `calculateLikes_BEFORE_INSERT` BEFORE INSERT ON `likes` FOR EACH ROW BEGIN
    DECLARE total_likes INT;
    DECLARE total_users INT;
    
    -- Obtener la cantidad total de likes del post actual
    SELECT COUNT(likes) INTO total_likes FROM posts WHERE postid = NEW.postid;
    
    -- Obtener la cantidad total de usuarios disponibles
    SELECT COUNT(*) INTO total_users FROM users;
    
    -- Si el número de likes es mayor o igual a la cantidad de usuarios disponibles, cancelar la inserción del like
    IF total_likes >= total_users THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pueden agregar más likes. La cantidad de likes ya ha alcanzado la cantidad de usuarios disponibles';
    END IF;
END


  -- VIEWS

-- ACTIVIDAD RECIENTE
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `vista_actividadreciente` AS
    SELECT 
        `p`.`postid` AS `postid`,
        `p`.`userid` AS `userid`,
        `p`.`content` AS `ContenidoPublicacion`,
        `p`.`date` AS `FechaPublicacion`,
        `c`.`commentid` AS `commentid`,
        `c`.`userid` AS `UsuarioComentario`,
        `c`.`content` AS `ContenidoComentario`,
        `c`.`date` AS `FechaComentario`,
        `l`.`likeid` AS `likeid`,
        `l`.`userid` AS `UsuarioLike`,
        `l`.`date` AS `FechaLike`
    FROM
        ((`posts` `p`
        LEFT JOIN `comments` `c` ON ((`p`.`postid` = `c`.`postid`)))
        LEFT JOIN `likes` `l` ON ((`p`.`postid` = `l`.`postid`)))
    ORDER BY `p`.`date` DESC

-- AMIGOS EN COMUN
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `vista_amigosencomun` AS
    SELECT 
        `a1`.`userid` AS `UsuarioID1`, `a2`.`userid` AS `UsuarioID2`
    FROM
        (`friends` `a1`
        JOIN `friends` `a2` ON (((`a1`.`userid` <> `a2`.`userid`)
            AND (`a1`.`userid2` = `a2`.`userid`))))

-- ESTADISTICAS DE USUARIOS
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `vista_estadisticasusuario` AS
    SELECT 
        `u`.`userid` AS `userid`,
        `u`.`fullname` AS `fullname`,
        COUNT(DISTINCT `p`.`postid`) AS `CantidadPublicaciones`,
        COUNT(DISTINCT `c`.`commentid`) AS `CantidadComentarios`,
        COUNT(DISTINCT `l`.`likeid`) AS `CantidadLikes`
    FROM
        (((`users` `u`
        LEFT JOIN `posts` `p` ON ((`u`.`userid` = `p`.`userid`)))
        LEFT JOIN `comments` `c` ON ((`u`.`userid` = `c`.`userid`)))
        LEFT JOIN `likes` `l` ON ((`u`.`userid` = `l`.`userid`)))
    GROUP BY `u`.`userid` , `u`.`fullname`

-- PUBLICACIONES POPULARES
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `vista_publicacionespopulares` AS
    SELECT 
        `p`.`postid` AS `postid`,
        `p`.`userid` AS `userid`,
        `p`.`content` AS `content`,
        `p`.`date` AS `date`,
        COUNT(`l`.`likeid`) AS `CantidadLikes`
    FROM
        (`posts` `p`
        LEFT JOIN `likes` `l` ON ((`p`.`postid` = `l`.`postid`)))
    GROUP BY `p`.`postid`
    ORDER BY `CantidadLikes` DESC

-- USUARIOS CON MISMA OCUPACIÓN
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `vista_usuariosmismaocupacion` AS
    SELECT 
        `u1`.`userid` AS `UsuarioID1`,
        `u1`.`fullname` AS `NombreUsuario1`,
        `u1`.`occupation` AS `Ocupacion`,
        `u2`.`userid` AS `UsuarioID2`,
        `u2`.`fullname` AS `NombreUsuario2`
    FROM
        (`users` `u1`
        JOIN `users` `u2` ON (((`u1`.`occupation` = `u2`.`occupation`)
            AND (`u1`.`userid` <> `u2`.`userid`))))
    ORDER BY `u1`.`occupation` , `u1`.`userid` , `u2`.`userid`

    -- FUNCIONES
  -- FUNCIÓN DE OBTENCIÓN DE RELACIONES / AMIGOS EN BASE AL USER ID 
CREATE DEFINER=`root`@`localhost` FUNCTION `ObtenerCantidadAmigos`(userid_param INT) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE cantidad_amigos INT;
    SELECT COUNT(*) INTO cantidad_amigos FROM friends WHERE userid = userid_param OR userid2 = userid_param;
    RETURN cantidad_amigos;
END

  -- FUNCIÓN DE OBTENCIÓN DE COMENTARIOS EN BASE AL USER ID
CREATE DEFINER=`root`@`localhost` FUNCTION `ObtenerTotalComentarios`(userid_param INT) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE total_comments INT;
    SELECT COUNT(*) INTO total_comments FROM comments WHERE userid = userid_param;
    RETURN total_comments;
END

      -- STORED PROCEDURES
    -- PROCEDIMIENTO PARA ACEPTAR UNA RELACIÓN / AMISTAD
CREATE DEFINER=`root`@`localhost` PROCEDURE `AgregarAmistad`(IN usuario1 INT, IN usuario2 INT)
BEGIN
    INSERT INTO friends (userid, userid2, state, friendshipdate) VALUES (usuario1, usuario2, 'Aceptado', NOW());
END

    -- PROCEDIMIENTO PARA MARCAR COMO LEÍDA UNA NOTIFICACIÓN
CREATE DEFINER=`root`@`localhost` PROCEDURE `MarcarNotificacionComoLeida`(IN notif_id INT)
BEGIN
    UPDATE notifications SET `read` = 1 WHERE notificationid = notif_id;
END