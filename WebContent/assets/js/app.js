/* 学籍通 · 轻量交互，无任何第三方依赖 */
(function () {
    'use strict';

    /* 移动端侧栏 */
    var sidebar = document.getElementById('sidebar');
    var mask = document.getElementById('sidebarMask');
    var toggle = document.getElementById('menuToggle');

    function closeSidebar() {
        if (sidebar) {
            sidebar.classList.remove('open');
        }
        if (mask) {
            mask.classList.remove('show');
        }
    }

    if (toggle) {
        toggle.addEventListener('click', function () {
            var open = sidebar.classList.toggle('open');
            if (mask) {
                mask.classList.toggle('show', open);
            }
        });
    }
    if (mask) {
        mask.addEventListener('click', closeSidebar);
    }
    document.querySelectorAll('.sidebar .nav-item').forEach(function (item) {
        item.addEventListener('click', function () {
            if (window.innerWidth <= 980) {
                closeSidebar();
            }
        });
    });

    /* 顶栏日期 */
    var today = document.getElementById('today');
    if (today) {
        var now = new Date();
        var weeks = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
        today.textContent = now.getFullYear() + ' 年 ' + (now.getMonth() + 1) + ' 月 '
            + now.getDate() + ' 日 · ' + weeks[now.getDay()];
    }

    /* 危险操作二次确认 */
    document.querySelectorAll('form[data-confirm]').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            var message = form.getAttribute('data-confirm') || '确定执行这个操作吗？';
            if (!window.confirm(message)) {
                event.preventDefault();
            }
        });
    });

    /* 密码显示 / 隐藏 */
    document.querySelectorAll('[data-toggle-password]').forEach(function (button) {
        button.addEventListener('click', function () {
            var input = document.getElementById(button.getAttribute('data-toggle-password'));
            if (!input) {
                return;
            }
            var show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            button.textContent = show ? '隐藏' : '显示';
        });
    });

    /* 下拉框自动提交 */
    document.querySelectorAll('select[data-autosubmit]').forEach(function (select) {
        select.addEventListener('change', function () {
            if (select.form) {
                select.form.submit();
            }
        });
    });

    /* 提示条自动消失 */
    var flash = document.querySelector('.flash');
    if (flash) {
        var close = flash.querySelector('.flash-close');
        var hide = function () {
            flash.classList.add('hide');
            window.setTimeout(function () {
                var wrap = flash.closest('.flash-wrap');
                if (wrap) {
                    wrap.remove();
                }
            }, 320);
        };
        if (close) {
            close.addEventListener('click', hide);
        }
        window.setTimeout(hide, 4600);
    }

    /* 成绩输入：回车跳到下一个输入框 */
    var scoreInputs = Array.prototype.slice.call(document.querySelectorAll('.score-input'));
    scoreInputs.forEach(function (input, index) {
        input.addEventListener('keydown', function (event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                var next = scoreInputs[index + 1];
                if (next) {
                    next.focus();
                    next.select();
                }
            }
        });
        input.addEventListener('focus', function () {
            input.select();
        });
    });

    /* 导入文件名回显 */
    var fileInput = document.querySelector('input[type="file"][data-filename]');
    if (fileInput) {
        fileInput.addEventListener('change', function () {
            var label = document.getElementById(fileInput.getAttribute('data-filename'));
            if (label) {
                label.textContent = fileInput.files.length ? fileInput.files[0].name : '未选择文件';
            }
        });
    }
})();
