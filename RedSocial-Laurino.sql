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