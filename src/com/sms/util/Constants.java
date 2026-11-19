package com.sms.util;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * 全局常量。
 */
public final class Constants {

    /** 系统里可选的学期。 */
    public static final List<String> TERMS = Collections.unmodifiableList(Arrays.asList(
            "2024-2025-1", "2024-2025-2", "2025-2026-1", "2025-2026-2"));

    /** 默认学期。 */
    public static final String DEFAULT_TERM = "2025-2026-1";

    /** 默认初始密码。 */
    public static final String DEFAULT_PASSWORD = "123456";

    public static final String ROLE_ADMIN = "admin";
    public static final String ROLE_TEACHER = "teacher";
    public static final String ROLE_STUDENT = "student";

    /** 每页条数。 */
    public static final int PAGE_SIZE = 10;

    private Constants() {
    }

    public static String roleName(String role) {
        if (ROLE_ADMIN.equals(role)) {
            return "管理员";
        }
        if (ROLE_TEACHER.equals(role)) {
            return "教师";
        }
        if (ROLE_STUDENT.equals(role)) {
            return "学生";
        }
        return "未知";
    }

    public static String[] genders() {
        return new String[]{"男", "女"};
    }

    public static String[] studentStatus() {
        return new String[]{"在读", "休学", "毕业"};
    }
}
