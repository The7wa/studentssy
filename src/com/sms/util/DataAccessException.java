package com.sms.util;

/**
 * 数据访问异常，统一包装 SQLException，方便上层给出友好提示。
 */
public class DataAccessException extends RuntimeException {

    public DataAccessException(String message, Throwable cause) {
        super(message, cause);
    }

    public DataAccessException(String message) {
        super(message);
    }
}
