var xhr = new XMLHttpRequest();
var abc = new XMLHttpRequest();

var p_flag = 0;
var u_flag = 0;

function doNameSearch() {
    t = document.getElementById("uname").value;
    xhr.onreadystatechange = doNameCheck;
    xhr.open('GET', 'http://127.0.0.1:9998/register/' + t, true);
    xhr.responseType = 'json';
    xhr.send(null);
}

function doNameCheck() {
    a = xhr.response;
    s = "";

    const uname = document.getElementById("uname").value;
    const pass = document.getElementById("pass").value;
    const button = document.getElementById("button1");

    if (uname.length == 0) {
        s = s + "ユーザーネームを入力してください。";
    } else if (uname.length <= 4 && uname.length >= 1) {
        s = s + "ユーザーネームが短すぎます。";
    } else if (uname.length >= 30) {
        s = s + "ユーザーネームが長すぎます。";
    } else if (a == 1) {
        s = s + "既に利用されているユーザーネームです。";
    } else if (uname.match(/^[^\x01-\x7E\xA1-\xDF]+$/)) {
        s = s + "半角文字で入力してください。";
    } else {
        s = s + "使用できます．";
        u_flag = 1;
    }
    document.getElementById("result_uname").innerHTML = s;

    if (pass.length == 0) {} else if (pass.length <= 7) {} else if (pass.length >= 80) {} else if (pass.match(/^[^\x01-\x7E\xA1-\xDF]+$/)) {} else if (pass.match(/^[^\a-\z\A-\Z\0-\9]/) == false) {} else {
        p_flag = 1;
    }

    if (p_flag == 1 && u_flag == 1) {
        button.disabled = false;
    } else {
        button.disabled = true;
    }
}

function doPassSearch() {
    abc.open('POST', '');
    abc.onreadystatechange = doPassCheck;
    abc.respnseType = 'json';
    abc.send(null);
}

function doPassCheck() {
    p = "";
    pass = document.getElementById("pass").value;
    if (pass.length == 0) {
        p = p + "パスワードを入力してください。";
    } else if (pass.length <= 7) {
        p = p + "8文字以上で入力してください。";
    } else if (pass.length >= 80) {
        p = p + "長すぎます。";
    } else if (pass.match(/^[^\x01-\x7E\xA1-\xDF]+$/)) {
        p = p + "半角文字で入力してください。";
    } else if (pass.match(/^[^\a-\z\A-\Z\0-\9]/) == false) {
        p = p + "小文字大文字数字を使用してください。";
    } else {
        p = p + "使用できます．";
        p_flag = 1;
    }
    document.getElementById("result_pass").innerHTML = p;

    if (p_flag == 1 && u_flag == 1) {
        button.disabled = false;
    } else {
        button.disabled = true;
    }

}

function doCheckButton() {
    xhr.open('POST', '');
    xhr.onreadystatechange = update;
    xhr.respnseType = 'json';
    xhr.send(null);
}

function update() {

    const uname = document.getElementById("uname").value;
    const pass = document.getElementById("pass").value;
    const button = document.getElementById("button1");

    p = "";
    if (uname.length == 0) {} else if (uname.length <= 4 && uname.length >= 1) {} else if (uname.length >= 30) {} else if (a == 1) {} else if (uname.match(/^[^\x01-\x7E\xA1-\xDF]+$/)) {} else {
        u_flag = 1;
    }


    if (pass.length == 0) {
        p = p + "パスワードを入力してください。";
    } else if (pass.length <= 7) {
        p = p + "8文字以上で入力してください。";
    } else if (pass.length >= 80) {
        p = p + "長すぎます。";
    } else if (pass.match(/^[^\x01-\x7E\xA1-\xDF]+$/)) {
        p = p + "半角文字で入力してください。";
    } else if (pass.match(/^[^\a-\z\A-\Z\0-\9]/) == false) {
        p = p + "小文字大文字数字を使用してください。";
    } else {
        p = p + "使用できます．";
        p_flag = 1;
    }
    document.getElementById("result_pass").innerHTML = p;

    if (p_flag == 1 && u_flag == 1) {
        button.disabled = false;
    } else {
        button.disabled = true;
    }
}