package com.sms.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * JDBC 连接工具。
 *
 * <p>配置读取顺序：环境变量 &gt; JVM 系统属性 &gt; classpath 下的 db.properties。
 * 因此平时只需要改 src/db.properties；部署到别的机器时也可以用环境变量覆盖，不必改代码。</p>
 */
public final class DBUtil {

    private static final Properties CONFIG = new Properties();

    static {
        try (InputStream in = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException("classpath 下找不到 db.properties");
            }
            CONFIG.load(in);
        } catch (Exception e) {
            throw new ExceptionInInitializerError("加载数据库配置失败：" + e.getMessage());
        }

        String driver = value("jdbc.driver", "com.mysql.cj.jdbc.Driver");
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                    "找不到 MySQL 驱动 " + driver + "，请确认 WEB-INF/lib 下有 mysql-connector-j-8.0.33.jar");
        }
    }

    private DBUtil() {
    }

    public static Connection getConnection() throws SQLException {
        String url = value("jdbc.url", "jdbc:mysql://localhost:3306/student_ms"
                + "?useUnicode=true&characterEncoding=utf8&useSSL=false"
                + "&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai");
        String username = value("jdbc.username", "root");
        String password = value("jdbc.password", "");
        return DriverManager.getConnection(url, username, password);
    }

    /**
     * 探活，登录页/错误页自检用。
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            return false;
        }
    }

    private static String value(String key, String defaultValue) {
        String envKey = "SMS_" + key.replace('.', '_').toUpperCase();
        String env = System.getenv(envKey);
        if (env != null && !env.trim().isEmpty()) {
            return env;
        }
        String sys = System.getProperty(key);
        if (sys != null && !sys.trim().isEmpty()) {
            return sys;
        }
        return CONFIG.getProperty(key, defaultValue);
    }
}
