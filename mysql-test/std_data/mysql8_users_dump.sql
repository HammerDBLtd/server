/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.11-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: 
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
CREATE USER ``@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$97qZy%&w6w2`2jZZ/8vqHO./k9hJmO8Lfqk9cXAvL9xsE3APioAvDQW8' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `O'Brien`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$.R\'`S^2)\Z>tVxOSDrZeBCRpWBu.HH1tP.Yj7UoWJLIdwsWvSoK2ui5oWd2' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_admin_chain_root`@`%` IDENTIFIED WITH 'caching_sha2_password' REQUIRE NONE PASSWORD EXPIRE ACCOUNT LOCK;
CREATE USER `m8_all_privs`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$XDmb\r#zg%biCp`x\')1fvkc7lVPKmU9OsPGOaq2iKZYdglrEuZjoVbl92DHI3' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_auth_caching_sha2`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$N27]4\"+  51]fxSBGtNNDVTdiuqGBNHVYHh15xsdqFhOpJYylSZ9tx2' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_auth_no_pwd`@`%` IDENTIFIED WITH 'caching_sha2_password' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_auth_sha256`@`%` REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT LOCK;
# WARNING: auth plugin 'sha256_password' not shipped with MariaDB; user created with no password - set a new password before login
CREATE USER `m8_col_priv`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$Q(v6)joOC\\[&\nfEUPhm2eX.sa0vMS.9aPsuAxQoGvFkhrXIxca5wG.o296' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_combined`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$i1OfA<VRK<Dph&e=F.HDUuym8i5jSx1kneUE0w.TCqkVKJbnQiZdRM6DdHg8' REQUIRE SSL WITH MAX_USER_CONNECTIONS 5 PASSWORD EXPIRE DEFAULT ACCOUNT LOCK;
CREATE USER `m8_db_underscore`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$}<%@~C#o-jw_j9?\\`78b.Gw6fFTyjGWDlVZNaPtZukQNreywHcKl1Mv6kEtC' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_default_role_many`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$O`[\")\r8w(QRF^RvvCxtX2TFTuuT.tej4z0tr2ABdBAa0MpJyHmJpcWa/' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_default_role_one`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$k(#*ZVLH\':3u8)M`7OyhK.NI2ju4oR/0aGUwKgtCaAS/giUXMCD5FLKpmC96' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_dumper`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005${(+imWM7t1eU+VJ!nhsfEEosMxYjwV0q04lHnfmpouyOvjlzalvFYy.6sR6' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_dyn_all_dropped`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$9PQb &pa`~.Ui%DVG5susO8X1fNWVguiT8K7gzX4NBa5uBdBvypftVLvD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_dyn_flush_collapse`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005${|{XZLV|.O:-?>GQG\nmSBf1jK0PqE1zsnma.xj4W/nHkrjo2taAS4k7h/VdfD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_dyn_grant_opt`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$\Z~,,k=?FY.~|e&c?~6vCSfvUaE2f3ZGStXaBsLONIoi9BOrLPNIm2J5SV6d0' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_dyn_mapped`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$J;+-\'|/6c08d1SQ.9tPergbLTxnMk3TY2VlREwtI4rVKXYC4GaiMJGD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_dyn_mixed`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$^}+I*%VNN;9diTWhVPy8ENGUcvtJE0HQ8LTBuSUs2QclYgNe7ahXIQjD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_dyn_unmapped`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$X i||v_l6AJ]plV.VohiM0ztKNpSZCXiP4nQ877nnElgKOoLrU5EXBY5G2' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_edge_at_in_name`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$+vtf)#aaJ1yt)z/k#\\OGzKHcfIuEfRRdQj43SrV7ClxoEGCPBaDBawzJvk6v.' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_edge_space`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$i~g1*7Q9%jk{.dSWWA0MAIe50lyP7HLnw9rGrC5kj/jg8bPchrmbSngj6' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_failed_login`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$4;\Z,WjN-4f*R\nHhX6UgWNvN/54VvhZIUV6AwJKYg85kDEoVfk0QXvTzLAB' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_func_exec`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$C7;{#M(}y:6X816YOCZf6IqE4rsVpxSKdBjZLxNqFKmlyctlzWu0YL/yTf79' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_host_dual`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$P\'gJYf~Yoj=b5BPH:rqi7w.R/wfCiXZ9.5TOtgO9JP34RYx0Db/bDyhBqaOD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_lock`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$6^YFF6e)lw]\'|rvQz6B3OfXcsozIlqfyMD2hVLLXcNV4SrLlK8Nc/7x7' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT LOCK;
CREATE USER `m8_max_conn`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$|PttVMit-5@6l\"r,6JMluRE2eiQUxmfW06fInNmAUtV/GATPAxRv.PYvjdD' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 1000 MAX_USER_CONNECTIONS 10 PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_multiscope`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$S\r>	&4nZ-\\xT~}xfQBxqqfsBuiwNhY7kjuKucnzgD249NW2w/MGWB5j7XQuA' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_partial_revoke`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$`*l^q\r-\\Qv\"0p\'f\"yhx54X83aD7NPyZVws/DnFYdBhqH3SuUyuuWkCegLJB' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_proc_exec`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$pT}>8jJ0o\"\\	1T5	.FEukd.nzGKwGiY8d5sZYb2jhUzk9L0ciIlYsKFKrd4iI7' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_proxy_target`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$NH?re;4\nu6<SzNNA4To9Gn8JHoWfmwP3cHrooEuQRweSVaRKbdniqulsj/' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_proxy_user`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$#ncoX<(y@%/4GzIqZgfnzY0irIKLk/ysOS2z4IgYOB4SV9zGLjycsfeA' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_pwd_expire_default`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$~Kw\Z-9-^cbUfMQ6&YShO1Ayx/UbqM3VMA1Nrx3rC525pXz4G.2BpnvMtKwD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_pwd_expire_interval`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$\Z+^Iad?S-{H1^Zuo:7y3S2YbDb/oMId6Qnwn0UoL6yEsVngbTlosvWn54TO0' REQUIRE NONE PASSWORD EXPIRE INTERVAL 90 DAY ACCOUNT UNLOCK;
CREATE USER `m8_pwd_expire_never`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$qVtrB3u8Hv[#s(~nX7mtrWqFPlvqVXEOkShwzqxL0wtiEEcYH3AggY4oo6' REQUIRE NONE PASSWORD EXPIRE NEVER ACCOUNT UNLOCK;
CREATE USER `m8_pwd_expire_now`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$#7@?:J\nTIUvSI%K7xVFlEiQJb7gi1AJ7KQSars80i5c/prKqdDqX0oC/94' REQUIRE NONE PASSWORD EXPIRE ACCOUNT UNLOCK;
CREATE USER `m8_pwd_history`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$k\Z*!ZxDr8Qw`t*CuQ5VPfv2vHUOKlxTacBC8kzLyr0b3L2l8A/4qnf/Sb3' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_pwd_require_current`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$.iZs=|*\\gK_fo^b6G.GLqpYKDSQRlVUWMaxsTLWEg2gvlAV0sbgtsoW6D' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_pwd_reuse`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$(\'f,Mf\ZU@\rL>pYXkWtBXiGsiAornx3CpQDbxK9SAMb9YTl17S58VkZY/u2' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_require_cipher`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$U3PR8/dC=yd[Z1#dnYhtRIMmtiDhiNs8sS734pa8DueTFXLKe6faIuELCRA' REQUIRE CIPHER 'ECDHE-RSA-AES128-GCM-SHA256' PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_require_ssl`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$ 7`<DQX}GmgcY+gt[HlkP26CcdauZkKteFr6KiJmkgO33bO5.TV00kkQm0Y51' REQUIRE SSL PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_require_x509`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$zYOZ-%.a\"<VBS`\\B/djLPP0w8HegKljdnzLvvktyLKbka0F3sz3m5Z4J69' REQUIRE X509 PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_resource_full`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$r\nc5r.!VSB\'g2PGbzKLsQh.nB1.ChLyunAnPLb.7immcaRvfIZ0pqiNJmJEC' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 5000 MAX_UPDATES_PER_HOUR 500 MAX_CONNECTIONS_PER_HOUR 100 MAX_USER_CONNECTIONS 25 PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_role*/starslash`@`%` IDENTIFIED WITH 'caching_sha2_password' REQUIRE NONE PASSWORD EXPIRE ACCOUNT LOCK;
CREATE USER `m8_role_static`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$xVUlRwlsIF\rRot`XMVejUYxwuJuMUgCxJ4Hu94YN02g7VSgP/HT.z/Hwu8' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_routine_admin`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$7V?8}L%9-?/IA v/7Pk5IvRFChA5iWQ1cH5EQA3Wny9AY59v0Z4UJ9Gq/' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_shared_user_1`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$c3?l.t@+\\g@J^*SmNcaKqCmwPhq3zBPNYqnYVAJPtAuRfqx7/Yml/6Pz3' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_shared_user_2`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$#9\nPa`Lmk\'\'m89*\rTZSJhIFMA5mSLF9Kg43ZoGX8ge85j1vsjdvgbPKaCU8' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_shared_user_3`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$6/2`JsDL<;X\\KF[SR0zZ5WtGp.N7h3S3GKNgAEDr1KfpAOAbM0qHeTM6o7' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_shared_user_4`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$@oc/10d]LPr.zTV_fR&OAH0LteDlOYSPu53dec3FmVP5RBgbqFBbwRobXqea4A' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_shared_user_5`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$3x\r(xH\'Ihtl] Ii2NL.34vh4UgtE7Klc/QzFmRW6yNozutTcplqvsJ1yOD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_simple`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$j5I,2\nKA8\"^eZuGjje8Jh0wIOBX2h3UfxD.tBCbAkwjwGYQQCmuCApCGD76' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_starslash_comment`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$\n\n.HE.\nM%wt\r)?l*auEmF1Mu5UHd82wQYsKqeecC.EFMYZHT6xnv6HdNnMopB2' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_starslash_escaped`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$zSm\Z%]\r#\"	I5,T\'Y4YK3jwzWY/FQt570iuNV87IH7ITyZ8tYtJKw8fZ2kf9' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_static_dyn_mix`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$,fG8 ~%Gk-2qCk_PL.0.2F.X7.3vmvzeOQ6XKipA7ebXhddb2pe5rEcpkdN/' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_static_priv`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$F=t*?l}FpiyMS3pW1g1Ar7ptnXi9E0U0t60iWf8mfL3FdDQJ8ovfv7' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_static_role_mix`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$?H1iQQg`v)\'f]Gw5cema8UnbNAl/lwO8mcui96NyqDUrFd5cENwKK/x332' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_system_grants`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$JxYsR%c\'A^3+O3c&`.JVn5zX1XOhPZ5yj6zYeig39nTzHyO4ZmQ9molSO0st4' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_unlock`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$}E,+4Lk\rHq\'& b61WG7Xtj7wfseRxUkVGNVld4mt62OpPCUv.GEbXrKD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_usage_only`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$U\n!Ww6N}XNBJ}S-w\riqLFmBhrZMZFW6NWV05WG2fRjK/ONw.mEkp42kx.wxsA' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_with_attribute`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$	%TZPC@	xc%hR|9PPPSmNC3n9IuX/QtrzooSa67SlXwtGa5sV1QyDkEJh7B' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_with_comment`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$;]7x{)Td,eKAi|7sWnJkvzdf0WM7Eetd2zJkqSH76sE11N/kI.f4J/qn4' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_用户`@`%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$k?k+?auD2#&Oq!tmhG9HYzsfMHf0.XGmXzbij51Jx6I.707/zegvo7fIRQT1' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_edge_wildcard_host`@`192.168.%.%` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$@x6<CydgGV(2!oCH5/b6AIc/jPt5le8jhi1YxIlw5OKZ36j7dSsPC5FRnEC' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER ``@`localhost` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$^;rDwKkBZT<]9v`	83oKY.S7lsgtElnHmuOkDgOW9CzrkJeAHkVfmgobvGB' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_host_dual`@`localhost` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$`%xEk5qES}W8!25|VWByicX..8jEM1pMer6BjTIGLbNKTRPVcihALcC4z6/' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `m8_host_localhost`@`localhost` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$\n?C\nEsoZ=Vz@!JGGgpoolfHzwfw2AEbVU5FqbYWbrl.94SSnzjJ/3PDYpD' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
CREATE USER `mysql.infoschema`@`localhost` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT LOCK;
CREATE USER `mysql.session`@`localhost` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT LOCK;
CREATE USER `mysql.sys`@`localhost` IDENTIFIED WITH 'caching_sha2_password' AS '$A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT LOCK;
CREATE USER `root`@`localhost` IDENTIFIED WITH 'caching_sha2_password' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
SELECT COALESCE(CURRENT_ROLE(),'NONE') into @current_role;
CREATE ROLE IF NOT EXISTS mariadb_dump_import_role;
GRANT mariadb_dump_import_role TO CURRENT_USER();
SET ROLE mariadb_dump_import_role;
/*M!100005 CREATE ROLE 'm8_default_a' */;
/*M!100005 GRANT 'm8_default_a' TO mariadb_dump_import_role WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_default_a' TO 'm8_combined'@'%' */;
/*M!100005 GRANT 'm8_default_a' TO 'm8_default_role_many'@'%' */;
/*M!100005 GRANT 'm8_default_a' TO 'm8_default_role_one'@'%' */;
/*M!100005 GRANT 'm8_default_a' TO 'm8_shared_user_1'@'%' */;
/*M!100005 GRANT 'm8_default_a' TO 'm8_shared_user_2'@'%' */;
/*M!100005 CREATE ROLE 'm8_default_b' */;
/*M!100005 GRANT 'm8_default_b' TO mariadb_dump_import_role WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_default_b' TO 'm8_default_role_many'@'%' */;
/*M!100005 CREATE ROLE 'm8_role_a' */;
/*M!100005 GRANT 'm8_role_a' TO mariadb_dump_import_role WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_role_a' TO 'm8_admin_chain_root'@'%' WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_role_a' TO 'm8_simple'@'%' WITH ADMIN OPTION */;
/*M!100005 CREATE ROLE 'm8_role_d' */;
/*M!100005 GRANT 'm8_role_d' TO mariadb_dump_import_role WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_role_d' TO 'm8_simple'@'%' */;
/*M!100005 CREATE ROLE 'm8_shared_role' */;
/*M!100005 GRANT 'm8_shared_role' TO mariadb_dump_import_role WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_shared_role' TO 'm8_shared_user_1'@'%' */;
/*M!100005 GRANT 'm8_shared_role' TO 'm8_shared_user_2'@'%' WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_shared_role' TO 'm8_shared_user_3'@'%' */;
/*M!100005 GRANT 'm8_shared_role' TO 'm8_shared_user_4'@'%' */;
/*M!100005 GRANT 'm8_shared_role' TO 'm8_shared_user_5'@'%' WITH ADMIN OPTION */;
/*M!100005 CREATE ROLE 'm8_role_b' */;
/*M!100005 GRANT 'm8_role_b' TO mariadb_dump_import_role WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_role_b' TO 'm8_role_a' WITH ADMIN OPTION */;
/*M!100005 CREATE ROLE 'm8_role_c' */;
/*M!100005 GRANT 'm8_role_c' TO mariadb_dump_import_role WITH ADMIN OPTION */;
/*M!100005 GRANT 'm8_role_c' TO 'm8_role_b' WITH ADMIN OPTION */;
GRANT USAGE ON *.* TO ``@`%`;
GRANT USAGE ON *.* TO `O'Brien`@`%`;
GRANT SELECT ON `m8_db`.* TO `O'Brien`@`%`;
GRANT USAGE ON *.* TO `m8_admin_chain_root`@`%`;
# WARNING: dropped MySQL privilege CREATE ROLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege DROP ROLE (no MariaDB equivalent)
/*M!100005 GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER, CREATE TABLESPACE ON *.* TO `m8_all_privs`@`%` WITH GRANT OPTION */;
# WARNING: dropped MySQL privilege APPLICATION_PASSWORD_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege AUDIT_ABORT_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege AUDIT_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege AUTHENTICATION_POLICY_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege BINLOG_ENCRYPTION_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege CLONE_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege ENCRYPTION_KEY_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FIREWALL_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_OPTIMIZER_COSTS (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_PRIVILEGES (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_STATUS (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_TABLES (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_USER_RESOURCES (no MariaDB equivalent)
# WARNING: dropped MySQL privilege GROUP_REPLICATION_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege GROUP_REPLICATION_STREAM (no MariaDB equivalent)
# WARNING: dropped MySQL privilege INNODB_REDO_LOG_ARCHIVE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege INNODB_REDO_LOG_ENABLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege OPTIMIZE_LOCAL_TABLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege PASSWORDLESS_USER_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege PERSIST_RO_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege RESOURCE_GROUP_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege RESOURCE_GROUP_USER (no MariaDB equivalent)
# WARNING: dropped MySQL privilege ROLE_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SENSITIVE_VARIABLES_OBSERVER (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SESSION_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_USER (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege TABLE_ENCRYPTION_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege TELEMETRY_LOG_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege TRANSACTION_GTID_TAG (no MariaDB equivalent)
# WARNING: dropped MySQL privilege XA_RECOVER_ADMIN (no MariaDB equivalent)
/*M!100005 GRANT SET USER, BINLOG REPLAY, BINLOG ADMIN, CONNECTION ADMIN, BINLOG REPLAY, REPLICATION SLAVE ADMIN, CONNECTION ADMIN, SET USER, SHOW CREATE ROUTINE ON *.* TO `m8_all_privs`@`%` WITH GRANT OPTION */;
GRANT USAGE ON *.* TO `m8_auth_caching_sha2`@`%`;
GRANT USAGE ON *.* TO `m8_auth_no_pwd`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_auth_no_pwd`@`%`;
GRANT USAGE ON *.* TO `m8_auth_sha256`@`%`;
GRANT USAGE ON *.* TO `m8_col_priv`@`%`;
GRANT SELECT (`col_a`, `col_underscore_b`), UPDATE (`col_a`) ON `m8_db`.`tab` TO `m8_col_priv`@`%`;
GRANT USAGE ON *.* TO `m8_combined`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_combined`@`%`;
/*M!100005 SET DEFAULT ROLE 'm8_default_a' FOR 'm8_combined'@'%' */;
GRANT USAGE ON *.* TO `m8_db_underscore`@`%`;
GRANT SELECT ON `m8_under_score_db`.* TO `m8_db_underscore`@`%`;
GRANT USAGE ON *.* TO `m8_default_a`@`%`;
GRANT USAGE ON *.* TO `m8_default_b`@`%`;
GRANT USAGE ON *.* TO `m8_default_role_many`@`%`;
/*M!100005 SET DEFAULT ROLE 'm8_default_a' FOR 'm8_default_role_many'@'%' */;
/*M!100005 SET DEFAULT ROLE 'm8_default_b' FOR 'm8_default_role_many'@'%' */;
GRANT USAGE ON *.* TO `m8_default_role_one`@`%`;
/*M!100005 SET DEFAULT ROLE 'm8_default_a' FOR 'm8_default_role_one'@'%' */;
GRANT SELECT, RELOAD, PROCESS, SHOW DATABASES, LOCK TABLES, REPLICATION CLIENT, SHOW VIEW, CREATE USER, EVENT, TRIGGER ON *.* TO `m8_dumper`@`%`;
GRANT SELECT ON `mysql`.* TO `m8_dumper`@`%`;
GRANT USAGE ON *.* TO `m8_dyn_all_dropped`@`%`;
# WARNING: dropped MySQL privilege AUDIT_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege CLONE_ADMIN (no MariaDB equivalent)
GRANT USAGE ON *.* TO `m8_dyn_flush_collapse`@`%`;
# WARNING: dropped MySQL privilege FLUSH_OPTIMIZER_COSTS (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_STATUS (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_TABLES (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_USER_RESOURCES (no MariaDB equivalent)
GRANT USAGE ON *.* TO `m8_dyn_grant_opt`@`%`;
/*M!100005 GRANT BINLOG REPLAY, BINLOG ADMIN, CONNECTION ADMIN ON *.* TO `m8_dyn_grant_opt`@`%` WITH GRANT OPTION */;
GRANT USAGE ON *.* TO `m8_dyn_mapped`@`%`;
/*M!100005 GRANT BINLOG REPLAY, BINLOG ADMIN ON *.* TO `m8_dyn_mapped`@`%` */;
GRANT USAGE ON *.* TO `m8_dyn_mixed`@`%`;
# WARNING: dropped MySQL privilege AUDIT_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
/*M!100005 GRANT BINLOG REPLAY, BINLOG ADMIN, CONNECTION ADMIN, BINLOG REPLAY, SHOW CREATE ROUTINE ON *.* TO `m8_dyn_mixed`@`%` */;
GRANT USAGE ON *.* TO `m8_dyn_unmapped`@`%`;
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
GRANT USAGE ON *.* TO `m8_edge_at_in_name`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_edge_at_in_name`@`%`;
GRANT USAGE ON *.* TO `m8_edge_space`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_edge_space`@`%`;
GRANT USAGE ON *.* TO `m8_failed_login`@`%`;
GRANT USAGE ON *.* TO `m8_func_exec`@`%`;
GRANT EXECUTE ON FUNCTION `m8_db`.`func_one` TO `m8_func_exec`@`%`;
GRANT USAGE ON *.* TO `m8_host_dual`@`%`;
GRANT SELECT ON `m8_db`.`tab2` TO `m8_host_dual`@`%`;
GRANT USAGE ON *.* TO `m8_lock`@`%`;
GRANT USAGE ON *.* TO `m8_max_conn`@`%`;
GRANT PROCESS ON *.* TO `m8_multiscope`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_multiscope`@`%`;
GRANT INSERT, UPDATE ON `m8_db`.`tab` TO `m8_multiscope`@`%`;
GRANT SELECT, INSERT ON *.* TO `m8_partial_revoke`@`%`;
# WARNING: partial REVOKE has no MariaDB equivalent, ignored: REVOKE INSERT ON `m8_db`.* FROM `m8_partial_revoke`@`%`
#   the wider GRANT remains in effect; re-grant at the narrower scope if needed.
GRANT USAGE ON *.* TO `m8_proc_exec`@`%`;
GRANT EXECUTE ON PROCEDURE `m8_db`.`proc_one` TO `m8_proc_exec`@`%`;
GRANT USAGE ON *.* TO `m8_proxy_target`@`%`;
GRANT USAGE ON *.* TO `m8_proxy_user`@`%`;
GRANT PROXY ON `m8_proxy_target`@`%` TO `m8_proxy_user`@`%`;
GRANT USAGE ON *.* TO `m8_pwd_expire_default`@`%`;
GRANT USAGE ON *.* TO `m8_pwd_expire_interval`@`%`;
GRANT USAGE ON *.* TO `m8_pwd_expire_never`@`%`;
GRANT USAGE ON *.* TO `m8_pwd_expire_now`@`%`;
GRANT USAGE ON *.* TO `m8_pwd_history`@`%`;
GRANT USAGE ON *.* TO `m8_pwd_require_current`@`%`;
GRANT USAGE ON *.* TO `m8_pwd_reuse`@`%`;
GRANT USAGE ON *.* TO `m8_require_cipher`@`%`;
GRANT USAGE ON *.* TO `m8_require_ssl`@`%`;
GRANT USAGE ON *.* TO `m8_require_x509`@`%`;
GRANT USAGE ON *.* TO `m8_resource_full`@`%`;
GRANT USAGE ON *.* TO `m8_role*/starslash`@`%`;
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
GRANT USAGE ON *.* TO `m8_role_a`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_role_a`@`%`;
GRANT USAGE ON *.* TO `m8_role_b`@`%`;
GRANT INSERT ON `m8_db`.* TO `m8_role_b`@`%`;
GRANT USAGE ON *.* TO `m8_role_c`@`%`;
GRANT UPDATE ON `m8_db`.* TO `m8_role_c`@`%`;
GRANT SHOW DATABASES ON *.* TO `m8_role_d`@`%`;
# WARNING: dropped MySQL privilege CREATE ROLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege DROP ROLE (no MariaDB equivalent)
GRANT USAGE ON *.* TO `m8_routine_admin`@`%`;
GRANT EXECUTE, CREATE ROUTINE, ALTER ROUTINE ON `m8_db`.* TO `m8_routine_admin`@`%`;
GRANT USAGE ON *.* TO `m8_shared_role`@`%`;
GRANT SELECT ON `m8_db`.`tab` TO `m8_shared_role`@`%`;
GRANT EXECUTE ON PROCEDURE `m8_db`.`proc_one` TO `m8_shared_role`@`%`;
GRANT USAGE ON *.* TO `m8_shared_user_1`@`%`;
GRANT USAGE ON *.* TO `m8_shared_user_2`@`%`;
GRANT USAGE ON *.* TO `m8_shared_user_3`@`%`;
GRANT USAGE ON *.* TO `m8_shared_user_4`@`%`;
GRANT USAGE ON *.* TO `m8_shared_user_5`@`%`;
GRANT USAGE ON *.* TO `m8_simple`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_simple`@`%`;
GRANT USAGE ON *.* TO `m8_starslash_comment`@`%`;
GRANT USAGE ON *.* TO `m8_starslash_escaped`@`%`;
GRANT SELECT ON *.* TO `m8_static_dyn_mix`@`%`;
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
/*M!100005 GRANT BINLOG REPLAY, BINLOG ADMIN ON *.* TO `m8_static_dyn_mix`@`%` */;
GRANT RELOAD, PROCESS ON *.* TO `m8_static_priv`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `m8_db`.* TO `m8_static_priv`@`%`;
# WARNING: dropped MySQL privilege CREATE ROLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege DROP ROLE (no MariaDB equivalent)
/*M!100005 GRANT SELECT, INSERT ON *.* TO `m8_static_role_mix`@`%` */;
GRANT USAGE ON *.* TO `m8_system_grants`@`%`;
GRANT SELECT ON `performance_schema`.* TO `m8_system_grants`@`%`;
GRANT SELECT ON `mysql`.`user` TO `m8_system_grants`@`%`;
GRANT USAGE ON *.* TO `m8_unlock`@`%`;
GRANT USAGE ON *.* TO `m8_usage_only`@`%`;
GRANT USAGE ON *.* TO `m8_with_attribute`@`%`;
GRANT USAGE ON *.* TO `m8_with_comment`@`%`;
GRANT USAGE ON *.* TO `m8_用户`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_用户`@`%`;
GRANT USAGE ON *.* TO `m8_edge_wildcard_host`@`192.168.%.%`;
GRANT SELECT ON `m8_db`.* TO `m8_edge_wildcard_host`@`192.168.%.%`;
GRANT USAGE ON *.* TO ``@`localhost`;
GRANT USAGE ON *.* TO `m8_host_dual`@`localhost`;
GRANT SELECT ON `m8_db`.* TO `m8_host_dual`@`localhost`;
GRANT USAGE ON *.* TO `m8_host_localhost`@`localhost`;
GRANT SELECT ON `m8_db`.* TO `m8_host_localhost`@`localhost`;
GRANT SELECT ON *.* TO `mysql.infoschema`@`localhost`;
# WARNING: dropped MySQL privilege AUDIT_ABORT_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FIREWALL_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_USER (no MariaDB equivalent)
GRANT SHUTDOWN, SUPER ON *.* TO `mysql.session`@`localhost`;
# WARNING: dropped MySQL privilege AUDIT_ABORT_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege AUTHENTICATION_POLICY_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege CLONE_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FIREWALL_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege PERSIST_RO_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SESSION_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_USER (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_VARIABLES_ADMIN (no MariaDB equivalent)
/*M!100005 GRANT CONNECTION ADMIN ON *.* TO `mysql.session`@`localhost` */;
GRANT SELECT ON `performance_schema`.* TO `mysql.session`@`localhost`;
GRANT SELECT ON `mysql`.`user` TO `mysql.session`@`localhost`;
GRANT USAGE ON *.* TO `mysql.sys`@`localhost`;
# WARNING: dropped MySQL privilege AUDIT_ABORT_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FIREWALL_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_USER (no MariaDB equivalent)
GRANT TRIGGER ON `sys`.* TO `mysql.sys`@`localhost`;
GRANT SELECT ON `sys`.`sys_config` TO `mysql.sys`@`localhost`;
# WARNING: dropped MySQL privilege CREATE ROLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege DROP ROLE (no MariaDB equivalent)
/*M!100005 GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER, CREATE TABLESPACE ON *.* TO `root`@`localhost` WITH GRANT OPTION */;
# WARNING: dropped MySQL privilege APPLICATION_PASSWORD_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege AUDIT_ABORT_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege AUDIT_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege AUTHENTICATION_POLICY_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege BACKUP_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege BINLOG_ENCRYPTION_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege CLONE_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege ENCRYPTION_KEY_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FIREWALL_EXEMPT (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_OPTIMIZER_COSTS (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_PRIVILEGES (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_STATUS (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_TABLES (no MariaDB equivalent)
# WARNING: dropped MySQL privilege FLUSH_USER_RESOURCES (no MariaDB equivalent)
# WARNING: dropped MySQL privilege GROUP_REPLICATION_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege GROUP_REPLICATION_STREAM (no MariaDB equivalent)
# WARNING: dropped MySQL privilege INNODB_REDO_LOG_ARCHIVE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege INNODB_REDO_LOG_ENABLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege OPTIMIZE_LOCAL_TABLE (no MariaDB equivalent)
# WARNING: dropped MySQL privilege PASSWORDLESS_USER_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege PERSIST_RO_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege RESOURCE_GROUP_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege RESOURCE_GROUP_USER (no MariaDB equivalent)
# WARNING: dropped MySQL privilege ROLE_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SENSITIVE_VARIABLES_OBSERVER (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SESSION_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_USER (no MariaDB equivalent)
# WARNING: dropped MySQL privilege SYSTEM_VARIABLES_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege TABLE_ENCRYPTION_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege TELEMETRY_LOG_ADMIN (no MariaDB equivalent)
# WARNING: dropped MySQL privilege TRANSACTION_GTID_TAG (no MariaDB equivalent)
# WARNING: dropped MySQL privilege XA_RECOVER_ADMIN (no MariaDB equivalent)
/*M!100005 GRANT SET USER, BINLOG REPLAY, BINLOG ADMIN, CONNECTION ADMIN, BINLOG REPLAY, REPLICATION SLAVE ADMIN, CONNECTION ADMIN, SET USER, SHOW CREATE ROUTINE ON *.* TO `root`@`localhost` WITH GRANT OPTION */;
GRANT PROXY ON ``@`` TO `root`@`localhost` WITH GRANT OPTION;
GRANT USAGE ON *.* TO `m8_default_a`@`%`;
GRANT USAGE ON *.* TO `m8_default_b`@`%`;
GRANT USAGE ON *.* TO `m8_role_a`@`%`;
GRANT SELECT ON `m8_db`.* TO `m8_role_a`@`%`;
GRANT USAGE ON *.* TO `m8_role_b`@`%`;
GRANT INSERT ON `m8_db`.* TO `m8_role_b`@`%`;
GRANT USAGE ON *.* TO `m8_role_c`@`%`;
GRANT UPDATE ON `m8_db`.* TO `m8_role_c`@`%`;
GRANT SHOW DATABASES ON *.* TO `m8_role_d`@`%`;
GRANT USAGE ON *.* TO `m8_shared_role`@`%`;
GRANT SELECT ON `m8_db`.`tab` TO `m8_shared_role`@`%`;
GRANT EXECUTE ON PROCEDURE `m8_db`.`proc_one` TO `m8_shared_role`@`%`;
SET ROLE NONE;
DROP ROLE mariadb_dump_import_role;
/*M!100203 EXECUTE IMMEDIATE CONCAT('SET ROLE ', @current_role) */;

USE mysql;

--
-- Dumping data for table `innodb_index_stats`
--

LOCK TABLES `innodb_index_stats` WRITE;
/*!40000 ALTER TABLE `innodb_index_stats` DISABLE KEYS */;
REPLACE INTO `innodb_index_stats` VALUES
('m8_db','tab','GEN_CLUST_INDEX','2026-05-27 14:44:49','n_diff_pfx01',0,1,'DB_ROW_ID'),
('m8_db','tab','GEN_CLUST_INDEX','2026-05-27 14:44:49','n_leaf_pages',1,NULL,'Number of leaf pages in the index'),
('m8_db','tab','GEN_CLUST_INDEX','2026-05-27 14:44:49','size',1,NULL,'Number of pages in the index'),
('m8_db','tab2','PRIMARY','2026-05-27 14:44:49','n_diff_pfx01',0,1,'id'),
('m8_db','tab2','PRIMARY','2026-05-27 14:44:49','n_leaf_pages',1,NULL,'Number of leaf pages in the index'),
('m8_db','tab2','PRIMARY','2026-05-27 14:44:49','size',1,NULL,'Number of pages in the index'),
('m8_under_score_db','t','GEN_CLUST_INDEX','2026-05-27 14:44:49','n_diff_pfx01',0,1,'DB_ROW_ID'),
('m8_under_score_db','t','GEN_CLUST_INDEX','2026-05-27 14:44:49','n_leaf_pages',1,NULL,'Number of leaf pages in the index'),
('m8_under_score_db','t','GEN_CLUST_INDEX','2026-05-27 14:44:49','size',1,NULL,'Number of pages in the index'),
('mysql','component','PRIMARY','2026-05-08 14:22:55','n_diff_pfx01',1,1,'component_id'),
('mysql','component','PRIMARY','2026-05-08 14:22:55','n_leaf_pages',1,NULL,'Number of leaf pages in the index'),
('mysql','component','PRIMARY','2026-05-08 14:22:55','size',1,NULL,'Number of pages in the index'),
('sys','sys_config','PRIMARY','2026-05-04 12:28:43','n_diff_pfx01',6,1,'variable'),
('sys','sys_config','PRIMARY','2026-05-04 12:28:43','n_leaf_pages',1,NULL,'Number of leaf pages in the index'),
('sys','sys_config','PRIMARY','2026-05-04 12:28:43','size',1,NULL,'Number of pages in the index');
/*!40000 ALTER TABLE `innodb_index_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `innodb_table_stats`
--

LOCK TABLES `innodb_table_stats` WRITE;
/*!40000 ALTER TABLE `innodb_table_stats` DISABLE KEYS */;
REPLACE INTO `innodb_table_stats` VALUES
('m8_db','tab','2026-05-27 14:44:49',0,1,0),
('m8_db','tab2','2026-05-27 14:44:49',0,1,0),
('m8_under_score_db','t','2026-05-27 14:44:49',0,1,0),
('mysql','component','2026-05-08 14:22:55',1,1,0),
('sys','sys_config','2026-05-04 12:28:43',6,1,0);
/*!40000 ALTER TABLE `innodb_table_stats` ENABLE KEYS */;
UNLOCK TABLES;

USE mysql;

--
-- Dumping data for table `time_zone`
--

LOCK TABLES `time_zone` WRITE;
/*!40000 ALTER TABLE `time_zone` DISABLE KEYS */;
/*!40000 ALTER TABLE `time_zone` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `time_zone_name`
--

LOCK TABLES `time_zone_name` WRITE;
/*!40000 ALTER TABLE `time_zone_name` DISABLE KEYS */;
/*!40000 ALTER TABLE `time_zone_name` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `time_zone_leap_second`
--

LOCK TABLES `time_zone_leap_second` WRITE;
/*!40000 ALTER TABLE `time_zone_leap_second` DISABLE KEYS */;
/*!40000 ALTER TABLE `time_zone_leap_second` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `time_zone_transition`
--

LOCK TABLES `time_zone_transition` WRITE;
/*!40000 ALTER TABLE `time_zone_transition` DISABLE KEYS */;
/*!40000 ALTER TABLE `time_zone_transition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `time_zone_transition_type`
--

LOCK TABLES `time_zone_transition_type` WRITE;
/*!40000 ALTER TABLE `time_zone_transition_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `time_zone_transition_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-05-27 16:44:56
