-- ============================================================
-- 学籍通 · 学生管理系统  数据库初始化脚本
-- 适用：MySQL 8.0 / utf8mb4
--
-- 执行方式（在项目根目录）：
--   mysql -uroot -p --default-character-set=utf8mb4 < sql/student_ms.sql
--
-- 说明：
--   1. 脚本会 DROP 并重建 student_ms 库，重复执行会清空旧数据；
--   2. 末尾会创建项目专用账号 sms_app / sms123456，只授予本库权限；
--   3. 演示账号见 README。
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS student_ms;
CREATE DATABASE student_ms DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE student_ms;

-- ------------------------------------------------------------
-- 1. 用户表（管理员 / 教师 / 学生）
-- ------------------------------------------------------------
CREATE TABLE sys_user (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(30)  NOT NULL UNIQUE COMMENT '登录名，学生账号即学号',
    password      VARCHAR(120) NOT NULL COMMENT 'PBKDF2 加盐哈希',
    real_name     VARCHAR(30)  NOT NULL,
    role          ENUM('admin','teacher','student') NOT NULL DEFAULT 'student',
    phone         VARCHAR(20)  DEFAULT NULL,
    email         VARCHAR(60)  DEFAULT NULL,
    status        TINYINT      NOT NULL DEFAULT 1 COMMENT '1 正常 0 停用',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_time DATETIME   DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户';

-- ------------------------------------------------------------
-- 2. 专业
-- ------------------------------------------------------------
CREATE TABLE major (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(10) NOT NULL UNIQUE,
    name        VARCHAR(40) NOT NULL,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='专业';

-- ------------------------------------------------------------
-- 3. 班级
-- ------------------------------------------------------------
CREATE TABLE clazz (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    code            VARCHAR(20) NOT NULL UNIQUE,
    name            VARCHAR(40) NOT NULL,
    major_id        INT NOT NULL,
    grade_year      SMALLINT NOT NULL,
    head_teacher_id INT DEFAULT NULL,
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_clazz_major FOREIGN KEY (major_id) REFERENCES major(id),
    CONSTRAINT fk_clazz_teacher FOREIGN KEY (head_teacher_id) REFERENCES sys_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级';

-- ------------------------------------------------------------
-- 4. 学生
-- ------------------------------------------------------------
CREATE TABLE student (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    student_no  VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(30) NOT NULL,
    gender      ENUM('男','女') NOT NULL DEFAULT '男',
    birth_date  DATE DEFAULT NULL,
    phone       VARCHAR(20) DEFAULT NULL,
    email       VARCHAR(60) DEFAULT NULL,
    address     VARCHAR(120) DEFAULT NULL,
    clazz_id    INT NOT NULL,
    enroll_year SMALLINT NOT NULL,
    status      ENUM('在读','休学','毕业') NOT NULL DEFAULT '在读',
    user_id     INT DEFAULT NULL UNIQUE COMMENT '关联登录账号',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_clazz FOREIGN KEY (clazz_id) REFERENCES clazz(id),
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生档案';

-- ------------------------------------------------------------
-- 5. 课程
-- ------------------------------------------------------------
CREATE TABLE course (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    code       VARCHAR(20) NOT NULL UNIQUE,
    name       VARCHAR(40) NOT NULL,
    credit     DECIMAL(3,1) NOT NULL DEFAULT 2.0,
    hours      SMALLINT NOT NULL DEFAULT 32,
    teacher_id INT DEFAULT NULL,
    term       VARCHAR(20) NOT NULL DEFAULT '2025-2026-1',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_course_teacher FOREIGN KEY (teacher_id) REFERENCES sys_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程';

-- ------------------------------------------------------------
-- 6. 成绩
-- ------------------------------------------------------------
CREATE TABLE score (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT NOT NULL,
    course_id   INT NOT NULL,
    term        VARCHAR(20) NOT NULL,
    score       DECIMAL(4,1) NOT NULL,
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_student_course_term (student_id, course_id, term),
    CONSTRAINT fk_score_student FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
    CONSTRAINT fk_score_course FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成绩';

-- ------------------------------------------------------------
-- 7. 初始数据
-- ------------------------------------------------------------
INSERT INTO sys_user (id, username, password, real_name, role, phone, email, status) VALUES
(1, 'admin', 'pbkdf2_sha256$120000$WUJq32B93lelEwyklJhzxw==$rEoCdIS2al8h8nZtnbGYcDaEyvSRVzJHtAuk8098wNE=', '系统管理员', 'admin', '13800000000', 'admin@example.com', 1),
(2, 't_zhangwei', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '张伟', 'teacher', '13900000000', 't_zhangwei@example.com', 1),
(3, 't_lina', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '李娜', 'teacher', '13900000001', 't_lina@example.com', 1),
(4, 't_wangqiang', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '王强', 'teacher', '13900000002', 't_wangqiang@example.com', 1),
(5, 't_liuyang', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '刘洋', 'teacher', '13900000003', 't_liuyang@example.com', 1),
(6, 't_chenjing', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '陈静', 'teacher', '13900000004', 't_chenjing@example.com', 1);

INSERT INTO sys_user (id, username, password, real_name, role, phone, email, status) VALUES
(7, '20230101', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '王雨桐', 'student', '13800001000', 's20230101@example.com', 1),
(8, '20230102', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '李昊然', 'student', '13800001001', 's20230102@example.com', 1),
(9, '20230103', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '张子墨', 'student', '13800001002', 's20230103@example.com', 1),
(10, '20230104', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '刘思远', 'student', '13800001003', 's20230104@example.com', 1),
(11, '20230105', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '陈欣怡', 'student', '13800001004', 's20230105@example.com', 1),
(12, '20230106', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '杨博文', 'student', '13800001005', 's20230106@example.com', 1),
(13, '20230107', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '赵一诺', 'student', '13800001006', 's20230107@example.com', 1),
(14, '20230108', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '黄梓涵', 'student', '13800001007', 's20230108@example.com', 1),
(15, '20230109', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '周俊杰', 'student', '13800001008', 's20230109@example.com', 1),
(16, '20230110', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '吴梦琪', 'student', '13800001009', 's20230110@example.com', 1),
(17, '20230111', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '徐子涵', 'student', '13800001010', 's20230111@example.com', 1),
(18, '20230112', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '孙浩然', 'student', '13800001011', 's20230112@example.com', 1),
(19, '20230113', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '马嘉怡', 'student', '13800001012', 's20230113@example.com', 1),
(20, '20230114', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '朱睿', 'student', '13800001013', 's20230114@example.com', 1),
(21, '20230115', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '胡佳宁', 'student', '13800001014', 's20230115@example.com', 1),
(22, '20230116', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '郭子豪', 'student', '13800001015', 's20230116@example.com', 1),
(23, '20230117', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '何雨欣', 'student', '13800001016', 's20230117@example.com', 1),
(24, '20230118', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '高远', 'student', '13800001017', 's20230118@example.com', 1),
(25, '20230119', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '林可欣', 'student', '13800001018', 's20230119@example.com', 1),
(26, '20230120', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '罗天宇', 'student', '13800001019', 's20230120@example.com', 1),
(27, '20230121', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '郑晓彤', 'student', '13800001020', 's20230121@example.com', 1),
(28, '20230122', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '谢文博', 'student', '13800001021', 's20230122@example.com', 1),
(29, '20230123', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '韩雨萱', 'student', '13800001022', 's20230123@example.com', 1),
(30, '20230124', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '唐嘉诚', 'student', '13800001023', 's20230124@example.com', 1),
(31, '20230125', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '冯雪', 'student', '13800001024', 's20230125@example.com', 1),
(32, '20230126', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '董宇航', 'student', '13800001025', 's20230126@example.com', 1),
(33, '20230127', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '曹思敏', 'student', '13800001026', 's20230127@example.com', 1),
(34, '20230128', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '彭子健', 'student', '13800001027', 's20230128@example.com', 1),
(35, '20230129', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '曾诗涵', 'student', '13800001028', 's20230129@example.com', 1),
(36, '20230130', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '蒋文轩', 'student', '13800001029', 's20230130@example.com', 1),
(37, '20230131', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '蔡梦瑶', 'student', '13800001030', 's20230131@example.com', 1),
(38, '20230132', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '余承泽', 'student', '13800001031', 's20230132@example.com', 1),
(39, '20230133', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '杜若溪', 'student', '13800001032', 's20230133@example.com', 1),
(40, '20230134', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '沈亦凡', 'student', '13800001033', 's20230134@example.com', 1),
(41, '20230135', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '卢静怡', 'student', '13800001034', 's20230135@example.com', 1),
(42, '20230136', 'pbkdf2_sha256$120000$l6wGYmefEgAIZjGfFURCIw==$y9cTcIQ9HWm6INHx/skP8xsrZK0jpKLjO9oTJ4oEo6E=', '潘子昂', 'student', '13800001035', 's20230136@example.com', 1);

INSERT INTO major (id, code, name) VALUES
(1, 'CS', '计算机科学与技术'),
(2, 'SE', '软件工程'),
(3, 'DS', '数据科学与大数据技术'),
(4, 'AI', '人工智能');

INSERT INTO clazz (id, code, name, major_id, grade_year, head_teacher_id) VALUES
(1, 'JZ2301', '计科 2301', 1, 2023, 2),
(2, 'JZ2302', '计科 2302', 1, 2023, 3),
(3, 'RG2301', '软工 2301', 2, 2023, 4),
(4, 'RG2302', '软工 2302', 2, 2023, 5),
(5, 'DS2301', '数据 2301', 3, 2023, 6),
(6, 'AI2301', '人工智能 2301', 4, 2023, 2);

INSERT INTO student (id, student_no, name, gender, birth_date, phone, email, address, clazz_id, enroll_year, status, user_id) VALUES
(1, '20230101', '王雨桐', '女', '2004-01-01', '13800001000', 's20230101@example.com', '浙江省杭州市', 1, 2023, '在读', 7),
(2, '20230102', '李昊然', '男', '2005-02-02', '13800001001', 's20230102@example.com', '江苏省南京市', 1, 2023, '在读', 8),
(3, '20230103', '张子墨', '男', '2004-03-03', '13800001002', 's20230103@example.com', '上海市浦东新区', 1, 2023, '在读', 9),
(4, '20230104', '刘思远', '男', '2005-04-04', '13800001003', 's20230104@example.com', '广东省广州市', 1, 2023, '在读', 10),
(5, '20230105', '陈欣怡', '女', '2004-05-05', '13800001004', 's20230105@example.com', '四川省成都市', 1, 2023, '在读', 11),
(6, '20230106', '杨博文', '男', '2005-06-06', '13800001005', 's20230106@example.com', '湖北省武汉市', 1, 2023, '在读', 12),
(7, '20230107', '赵一诺', '女', '2004-07-07', '13800001006', 's20230107@example.com', '浙江省杭州市', 2, 2023, '在读', 13),
(8, '20230108', '黄梓涵', '女', '2005-08-08', '13800001007', 's20230108@example.com', '江苏省南京市', 2, 2023, '在读', 14),
(9, '20230109', '周俊杰', '男', '2004-09-09', '13800001008', 's20230109@example.com', '上海市浦东新区', 2, 2023, '在读', 15),
(10, '20230110', '吴梦琪', '女', '2005-10-10', '13800001009', 's20230110@example.com', '广东省广州市', 2, 2023, '在读', 16),
(11, '20230111', '徐子涵', '女', '2004-11-11', '13800001010', 's20230111@example.com', '四川省成都市', 2, 2023, '在读', 17),
(12, '20230112', '孙浩然', '男', '2005-12-12', '13800001011', 's20230112@example.com', '湖北省武汉市', 2, 2023, '在读', 18),
(13, '20230113', '马嘉怡', '女', '2004-01-13', '13800001012', 's20230113@example.com', '浙江省杭州市', 3, 2023, '在读', 19),
(14, '20230114', '朱睿', '男', '2005-02-14', '13800001013', 's20230114@example.com', '江苏省南京市', 3, 2023, '在读', 20),
(15, '20230115', '胡佳宁', '女', '2004-03-15', '13800001014', 's20230115@example.com', '上海市浦东新区', 3, 2023, '在读', 21),
(16, '20230116', '郭子豪', '男', '2005-04-16', '13800001015', 's20230116@example.com', '广东省广州市', 3, 2023, '在读', 22),
(17, '20230117', '何雨欣', '女', '2004-05-17', '13800001016', 's20230117@example.com', '四川省成都市', 3, 2023, '在读', 23),
(18, '20230118', '高远', '男', '2005-06-18', '13800001017', 's20230118@example.com', '湖北省武汉市', 3, 2023, '在读', 24),
(19, '20230119', '林可欣', '女', '2004-07-19', '13800001018', 's20230119@example.com', '浙江省杭州市', 4, 2023, '在读', 25),
(20, '20230120', '罗天宇', '男', '2005-08-20', '13800001019', 's20230120@example.com', '江苏省南京市', 4, 2023, '在读', 26),
(21, '20230121', '郑晓彤', '女', '2004-09-21', '13800001020', 's20230121@example.com', '上海市浦东新区', 4, 2023, '在读', 27),
(22, '20230122', '谢文博', '男', '2005-10-22', '13800001021', 's20230122@example.com', '广东省广州市', 4, 2023, '在读', 28),
(23, '20230123', '韩雨萱', '女', '2004-11-23', '13800001022', 's20230123@example.com', '四川省成都市', 4, 2023, '在读', 29),
(24, '20230124', '唐嘉诚', '男', '2005-12-24', '13800001023', 's20230124@example.com', '湖北省武汉市', 4, 2023, '在读', 30),
(25, '20230125', '冯雪', '女', '2004-01-25', '13800001024', 's20230125@example.com', '浙江省杭州市', 5, 2023, '在读', 31),
(26, '20230126', '董宇航', '男', '2005-02-26', '13800001025', 's20230126@example.com', '江苏省南京市', 5, 2023, '在读', 32),
(27, '20230127', '曹思敏', '女', '2004-03-27', '13800001026', 's20230127@example.com', '上海市浦东新区', 5, 2023, '在读', 33),
(28, '20230128', '彭子健', '男', '2005-04-01', '13800001027', 's20230128@example.com', '广东省广州市', 5, 2023, '在读', 34),
(29, '20230129', '曾诗涵', '女', '2004-05-02', '13800001028', 's20230129@example.com', '四川省成都市', 5, 2023, '在读', 35),
(30, '20230130', '蒋文轩', '男', '2005-06-03', '13800001029', 's20230130@example.com', '湖北省武汉市', 5, 2023, '在读', 36),
(31, '20230131', '蔡梦瑶', '女', '2004-07-04', '13800001030', 's20230131@example.com', '浙江省杭州市', 6, 2023, '在读', 37),
(32, '20230132', '余承泽', '男', '2005-08-05', '13800001031', 's20230132@example.com', '江苏省南京市', 6, 2023, '在读', 38),
(33, '20230133', '杜若溪', '女', '2004-09-06', '13800001032', 's20230133@example.com', '上海市浦东新区', 6, 2023, '在读', 39),
(34, '20230134', '沈亦凡', '男', '2005-10-07', '13800001033', 's20230134@example.com', '广东省广州市', 6, 2023, '在读', 40),
(35, '20230135', '卢静怡', '女', '2004-11-08', '13800001034', 's20230135@example.com', '四川省成都市', 6, 2023, '在读', 41),
(36, '20230136', '潘子昂', '男', '2005-12-09', '13800001035', 's20230136@example.com', '湖北省武汉市', 6, 2023, '在读', 42);

INSERT INTO course (id, code, name, credit, hours, teacher_id, term) VALUES
(1, 'CS101', '程序设计基础', 4.0, 64, 2, '2025-2026-1'),
(2, 'CS102', '数据结构', 4.0, 64, 2, '2025-2026-1'),
(3, 'CS201', '数据库原理', 3.0, 48, 3, '2025-2026-1'),
(4, 'CS202', '计算机网络', 3.0, 48, 4, '2025-2026-1'),
(5, 'CS203', '操作系统', 3.5, 56, 5, '2025-2026-1'),
(6, 'MA101', '高等数学', 5.0, 80, 6, '2025-2026-1'),
(7, 'EN101', '大学英语', 2.0, 32, 3, '2025-2026-1'),
(8, 'SE201', '软件工程', 3.0, 48, 4, '2025-2026-1');

INSERT INTO score (student_id, course_id, term, score) VALUES
(1, 1, '2025-2026-1', 62.0),
(1, 2, '2025-2026-1', 69.0),
(1, 3, '2025-2026-1', 76.0),
(1, 6, '2025-2026-1', 97.0),
(1, 7, '2025-2026-1', 59.0),
(2, 1, '2025-2026-1', 75.0),
(2, 2, '2025-2026-1', 82.0),
(2, 3, '2025-2026-1', 89.0),
(2, 6, '2025-2026-1', 65.0),
(2, 7, '2025-2026-1', 72.0),
(3, 1, '2025-2026-1', 88.0),
(3, 2, '2025-2026-1', 95.0),
(3, 3, '2025-2026-1', 57.0),
(3, 6, '2025-2026-1', 78.0),
(3, 7, '2025-2026-1', 85.0),
(4, 1, '2025-2026-1', 56.0),
(4, 2, '2025-2026-1', 63.0),
(4, 3, '2025-2026-1', 70.0),
(4, 6, '2025-2026-1', 91.0),
(4, 7, '2025-2026-1', 98.0),
(5, 1, '2025-2026-1', 69.0),
(5, 2, '2025-2026-1', 76.0),
(5, 3, '2025-2026-1', 83.0),
(5, 6, '2025-2026-1', 59.0),
(5, 7, '2025-2026-1', 66.0),
(6, 1, '2025-2026-1', 82.0),
(6, 2, '2025-2026-1', 89.0),
(6, 3, '2025-2026-1', 96.0),
(6, 6, '2025-2026-1', 72.0),
(6, 7, '2025-2026-1', 79.0),
(7, 1, '2025-2026-1', 95.0),
(7, 2, '2025-2026-1', 57.0),
(7, 3, '2025-2026-1', 64.0),
(7, 6, '2025-2026-1', 85.0),
(7, 7, '2025-2026-1', 92.0),
(8, 1, '2025-2026-1', 63.0),
(8, 2, '2025-2026-1', 70.0),
(8, 3, '2025-2026-1', 77.0),
(8, 6, '2025-2026-1', 98.0),
(8, 7, '2025-2026-1', 60.0),
(9, 1, '2025-2026-1', 76.0),
(9, 2, '2025-2026-1', 83.0),
(9, 3, '2025-2026-1', 90.0),
(9, 6, '2025-2026-1', 66.0),
(9, 7, '2025-2026-1', 73.0),
(10, 1, '2025-2026-1', 89.0),
(10, 2, '2025-2026-1', 96.0),
(10, 3, '2025-2026-1', 58.0),
(10, 6, '2025-2026-1', 79.0),
(10, 7, '2025-2026-1', 86.0),
(11, 1, '2025-2026-1', 57.0),
(11, 2, '2025-2026-1', 64.0),
(11, 3, '2025-2026-1', 71.0),
(11, 6, '2025-2026-1', 92.0),
(11, 7, '2025-2026-1', 99.0),
(12, 1, '2025-2026-1', 70.0),
(12, 2, '2025-2026-1', 77.0),
(12, 3, '2025-2026-1', 84.0),
(12, 6, '2025-2026-1', 60.0),
(12, 7, '2025-2026-1', 67.0),
(13, 1, '2025-2026-1', 83.0),
(13, 8, '2025-2026-1', 87.0),
(13, 3, '2025-2026-1', 97.0),
(13, 6, '2025-2026-1', 73.0),
(13, 7, '2025-2026-1', 80.0),
(14, 1, '2025-2026-1', 96.0),
(14, 8, '2025-2026-1', 55.0),
(14, 3, '2025-2026-1', 65.0),
(14, 6, '2025-2026-1', 86.0),
(14, 7, '2025-2026-1', 93.0),
(15, 1, '2025-2026-1', 64.0),
(15, 8, '2025-2026-1', 68.0),
(15, 3, '2025-2026-1', 78.0),
(15, 6, '2025-2026-1', 99.0),
(15, 7, '2025-2026-1', 61.0),
(16, 1, '2025-2026-1', 77.0),
(16, 8, '2025-2026-1', 81.0),
(16, 3, '2025-2026-1', 91.0),
(16, 6, '2025-2026-1', 67.0),
(16, 7, '2025-2026-1', 74.0),
(17, 1, '2025-2026-1', 90.0),
(17, 8, '2025-2026-1', 94.0),
(17, 3, '2025-2026-1', 59.0),
(17, 6, '2025-2026-1', 80.0),
(17, 7, '2025-2026-1', 87.0),
(18, 1, '2025-2026-1', 58.0),
(18, 8, '2025-2026-1', 62.0),
(18, 3, '2025-2026-1', 72.0),
(18, 6, '2025-2026-1', 93.0),
(18, 7, '2025-2026-1', 55.0),
(19, 1, '2025-2026-1', 71.0),
(19, 8, '2025-2026-1', 75.0),
(19, 3, '2025-2026-1', 85.0),
(19, 6, '2025-2026-1', 61.0),
(19, 7, '2025-2026-1', 68.0),
(20, 1, '2025-2026-1', 84.0),
(20, 8, '2025-2026-1', 88.0),
(20, 3, '2025-2026-1', 98.0),
(20, 6, '2025-2026-1', 74.0),
(20, 7, '2025-2026-1', 81.0),
(21, 1, '2025-2026-1', 97.0),
(21, 8, '2025-2026-1', 56.0),
(21, 3, '2025-2026-1', 66.0),
(21, 6, '2025-2026-1', 87.0),
(21, 7, '2025-2026-1', 94.0),
(22, 1, '2025-2026-1', 65.0),
(22, 8, '2025-2026-1', 69.0),
(22, 3, '2025-2026-1', 79.0),
(22, 6, '2025-2026-1', 55.0),
(22, 7, '2025-2026-1', 62.0),
(23, 1, '2025-2026-1', 78.0),
(23, 8, '2025-2026-1', 82.0),
(23, 3, '2025-2026-1', 92.0),
(23, 6, '2025-2026-1', 68.0),
(23, 7, '2025-2026-1', 75.0),
(24, 1, '2025-2026-1', 91.0),
(24, 8, '2025-2026-1', 95.0),
(24, 3, '2025-2026-1', 60.0),
(24, 6, '2025-2026-1', 81.0),
(24, 7, '2025-2026-1', 88.0),
(25, 1, '2025-2026-1', 59.0),
(25, 3, '2025-2026-1', 73.0),
(25, 5, '2025-2026-1', 87.0),
(25, 6, '2025-2026-1', 94.0),
(25, 7, '2025-2026-1', 56.0),
(26, 1, '2025-2026-1', 72.0),
(26, 3, '2025-2026-1', 86.0),
(26, 5, '2025-2026-1', 55.0),
(26, 6, '2025-2026-1', 62.0),
(26, 7, '2025-2026-1', 69.0),
(27, 1, '2025-2026-1', 85.0),
(27, 3, '2025-2026-1', 99.0),
(27, 5, '2025-2026-1', 68.0),
(27, 6, '2025-2026-1', 75.0),
(27, 7, '2025-2026-1', 82.0),
(28, 1, '2025-2026-1', 98.0),
(28, 3, '2025-2026-1', 67.0),
(28, 5, '2025-2026-1', 81.0),
(28, 6, '2025-2026-1', 88.0),
(28, 7, '2025-2026-1', 95.0),
(29, 1, '2025-2026-1', 66.0),
(29, 3, '2025-2026-1', 80.0),
(29, 5, '2025-2026-1', 94.0),
(29, 6, '2025-2026-1', 56.0),
(29, 7, '2025-2026-1', 63.0),
(30, 1, '2025-2026-1', 79.0),
(30, 3, '2025-2026-1', 93.0),
(30, 5, '2025-2026-1', 62.0),
(30, 6, '2025-2026-1', 69.0),
(30, 7, '2025-2026-1', 76.0),
(31, 1, '2025-2026-1', 92.0),
(31, 3, '2025-2026-1', 61.0),
(31, 5, '2025-2026-1', 75.0),
(31, 6, '2025-2026-1', 82.0),
(31, 7, '2025-2026-1', 89.0),
(32, 1, '2025-2026-1', 60.0),
(32, 3, '2025-2026-1', 74.0),
(32, 5, '2025-2026-1', 88.0),
(32, 6, '2025-2026-1', 95.0),
(32, 7, '2025-2026-1', 57.0),
(33, 1, '2025-2026-1', 73.0),
(33, 3, '2025-2026-1', 87.0),
(33, 5, '2025-2026-1', 56.0),
(33, 6, '2025-2026-1', 63.0),
(33, 7, '2025-2026-1', 70.0),
(34, 1, '2025-2026-1', 86.0),
(34, 3, '2025-2026-1', 55.0),
(34, 5, '2025-2026-1', 69.0),
(34, 6, '2025-2026-1', 76.0),
(34, 7, '2025-2026-1', 83.0),
(35, 1, '2025-2026-1', 99.0),
(35, 3, '2025-2026-1', 68.0),
(35, 5, '2025-2026-1', 82.0),
(35, 6, '2025-2026-1', 89.0),
(35, 7, '2025-2026-1', 96.0),
(36, 1, '2025-2026-1', 67.0),
(36, 3, '2025-2026-1', 81.0),
(36, 5, '2025-2026-1', 95.0),
(36, 6, '2025-2026-1', 57.0),
(36, 7, '2025-2026-1', 64.0);

-- ------------------------------------------------------------
-- 8. 项目专用数据库账号（可删掉，改用 root）
-- ------------------------------------------------------------
CREATE USER IF NOT EXISTS 'sms_app'@'localhost' IDENTIFIED BY 'sms123456';
ALTER USER 'sms_app'@'localhost' IDENTIFIED BY 'sms123456';
GRANT SELECT, INSERT, UPDATE, DELETE ON student_ms.* TO 'sms_app'@'localhost';

SET FOREIGN_KEY_CHECKS = 1;
