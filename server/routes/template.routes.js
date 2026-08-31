const express = require("express");
const users = express.Router();
const cors = require("cors");
const db = require("../database/config");
// const csrf = require('csurf');
// const csrfProtection = csrf();
const security = require('../database/security');
//const { parse } = require("dotenv/types");
const path = require('path');
const baseUrl = require('../database/config.json');
const e = require("express");

users.use(cors());
users.use(security.verifyAutheticity);

// to get multiple data from multiple result set just use this code:
// type: db.sequelize.QueryTypes.SELECT
// and to extract a specific result set use:
// data[1] - (1 is the result set index)

users.get('/get_all', (req, res) => {
    db.sequelize.query('CALL sp_users_get(:keyword, :page_no, :limit, :sort_column, :sort_type)', {
        type: db.sequelize.QueryTypes.SELECT,
        replacements: {
            keyword: req.body.keyword,
            page_no: req.body.page_no,
            limit: req.body.limit,
            sort_column: req.body.sort_column,
            sort_type: req.body.sort_type
        }
    }).then((data) => {
        res.json({ error: false, data: data });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/get_all2', (req, res) => {
    db.sequelize.query('CALL sp_users_get(:keyword, :page_no, :limit, :sort_column, :sort_type)', {
        type: db.sequelize.QueryTypes.SELECT,
        replacements: {
            keyword: req.body.keyword,
            page_no: req.body.page_no,
            limit: req.body.limit,
            sort_column: req.body.sort_column,
            sort_type: req.body.sort_type
        }
    }).then((data) => {
        res.json({ error: false, data: db.MultiQueryResult(data) });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});


users.get('/get_per_user', (req, res) => {
    db.sequelize.query('CALL sp_users_get_per_user(:id)', {
        type: db.sequelize.QueryTypes.SELECT,
        replacements: {
            id: req.body.id
        }
    }).then((data) => {
        res.json({ error: false, data: data });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.get('/get_per_user_role', (req, res) => {
    db.sequelize.query('CALL sp_users_get_per_role(:user_role_id)', {
        replacements: {
            user_role_id: req.query.user_role_id
        }
    }).then((data) => {
        res.json({ error: false, data: data });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/add', (req, res) => {
    db.sequelize.query('CALL sp_users_add( :department_id, :username, :fullname, :firstname, :middlename, :lastname, :email, :contact_no, :image, :birthdate, :address, :area, :town, :city, :district, :state, :country, :added_by, :user_type, :users_role_id, :password)', {
        replacements: {
            department_id: parseInt(req.body.department_id),
            username: req.body.username,
            fullname: req.body.fullname,
            firstname: req.body.firstname,
            middlename: req.body.middlename,
            lastname: req.body.lastname,
            email: req.body.email,
            contact_no: req.body.contact_no,
            image: parseInt(req.body.image),
            birthdate: req.body.birthdate,
            address: req.body.address,
            area: req.body.area,
            town: req.body.town,
            city: req.body.city,
            district: req.body.district,
            state: req.body.state,
            country: req.body.country,
            added_by: req.body.added_by,
            user_type: req.body.user_type,
            users_role_id: parseInt(req.body.users_role_id),
            password: req.body.password
        }
    }).then(data => {
        ret = data[0]["_ret"];
        if (ret === "fullname_exist") {
            res.send({ error: true, message: `Name '${req.body.fullname}' already taken.` });
        } else if (ret === "username_exist") {
            res.send({ error: true, message: `Username '${req.body.username}' already taken.` });
        }
        else {
            res.send({ error: false, message: `User Successfully added.` });
        }
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/edit', (req, res) => {
    db.sequelize.query('CALL sp_users_edit(:department_id, :username, :fullname, :firstname, :middlename, :lastname, :email,:contact_no, :image_file_id, :birthdate, :address, :area, :town, :city, :district, :state, :country, :user_type, :users_role_id, :id)', {
        replacements: {
            department_id: req.body.department_id,
            username: req.body.username,
            fullname: req.body.fullname,
            firstname: req.body.firstname,
            middlename: req.body.middlename,
            lastname: req.body.lastname,
            email: req.body.email,
            contact_no: req.body.contact_no,
            image_file_id: req.body.image,
            birthdate: req.body.birthdate,
            address: req.body.address,
            area: req.body.area,
            town: req.body.town,
            city: req.body.city,
            district: req.body.district,
            state: req.body.state,
            country: req.body.country,
            user_type: req.body.user_type,
            users_role_id: parseInt(req.body.users_role_id),
            id: req.body.id
        }
    }).then(data => {
        ret = data[0]["_ret"];
        if (ret === "fullname_exist") {
            res.send({ error: true, message: `Name '${req.body.fullname}' already taken.` });
        } else if (ret === "short_name_exist") {
            res.send({ error: true, message: `Username '${req.body.username}' already taken.` });
        }
        else {
            res.send({ error: false, message: `Successfully updated.` });
        }
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/change_password', (req, res) => {
    db.sequelize.query('CALL sp_users_change_password(:id,:new_password)', {
        replacements: {
            id: req.body.user_id,
            new_password: req.body.new_password
        }
    }).then((data) => {
        res.json({ error: false, message: "Changed password successfully." });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.delete('/delete', (req, res) => {
    db.sequelize.query('CALL sp_users_delete(:id)', {
        replacements: {
            id: req.query.id
        }
    }).then(data => {
        ret = data[0]["_ret"];
        if (ret === "delete_successful") {
            res.send({ error: false, message: `User successfully deleted.` });
        } else if (ret === "value_not_exist") {
            res.send({ error: true, message: `User not found. Please try again.` });
        } else {
            res.send({ error: true, message: 'Unknown error!' });
        }
    }).catch(err => {
        res.send({ error: true, message: `Error deleting data! ${err}` });
    });
});

users.post('/is_active', (req, res) => {
    db.sequelize.query('CALL sp_users_isactive(:id)', {
        replacements: {
            id: req.body.id
        }
    }).then((data) => {
        ret = data[0]["_ret"];
        if (ret === "change_status_successful") {
            res.send({ error: false, message: `Status successfully updated.` });
        } else if (ret === "value_not_exist") {
            res.send({ error: true, message: `User not found. Please try again.` });
        } else {
            res.send({ error: true, message: 'Unknown error!' });
        }
    }).catch(err => {
        res.send({ error: true, message: `Error deleting data! ${err}` });
    });
});

users.get('/get_department', (req, res) => {
    db.sequelize.query('CALL sp_department_get_all()').then((data) => {
        res.json({ error: false, data: data });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/remove_user_access', (req, res) => {
    db.sequelize.query('CALL sp_users_access_remove(:users_id)', {
        replacements: {
            users_id: req.body.users_id
        }
    }).then((data) => {
        res.send({ error: false, message: `User successfully removed.` });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/reset_password', (req, res) => {

    let length = 6,
        charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        retVal = "";
    for (let i = 0, n = charset.length; i < length; ++i) {
        retVal += charset.charAt(Math.floor(Math.random() * n));
    }

    db.sequelize.query('CALL sp_users_change_password(:id,:new_password)', {
        replacements: {
            id: req.body.user_id,
            new_password: retVal,
        }
    }).then((data) => {

        let text = `Your username & password to https://grandtcondoconnect.com is\nPassword:${retVal}`;
        const respo = db.emailRequest({
            to: data[0]["email"],
            subject: "Your new password",
            text: text,
        });
        res.json({ error: false, message: "Password reset successfully." });

    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/changepp', function (req, res) {
    const file = req.body.fileToUpload;
    const filetype = file.split(';')[0].split('/')[1];
    if (filetype === "jpg" || filetype === "png" || filetype === "jpeg") {
        const charindex = file.indexOf("base64,");
        var matches = file.substring(charindex + 6);
        var base64Data = Buffer.from(matches, 'base64');
        let reqPath = path.join(__dirname, '..', 'public', 'users_images', '/');
        let filename = `${+new Date}.${filetype}`;
        uploadPath = reqPath + filename;
        require("fs").writeFile(uploadPath, base64Data, 'base64', function (err) {
            if (err) {
                res.send({ error: true, message: "Error 532: Oh uh! an error and occured when uploading the image. Pls try again later", data: err });
            } else {
                db.sequelize.query('CALL sp_users_update_pp(:file_name, :user_id)', {
                    replacements: {
                        file_name: filename,
                        user_id: req.body.user_id
                    }
                }).then(data => {
                    let ret = data[0]["_ret"];
                    res.send({ error: false, message: `Profile picture successfully updated.`, data: { folder: "users_images", filename: filename, file_id: ret } });
                }).catch((err) => {
                    res.send({ error: true, message: `Error 534: ${err}` });
                });
            }
        });
    } else {
        res.send({ error: true, message: `Error 536: ${filetype} is an invalid image file type. Only upload jpeg and png image format!` });
    }
});

users.post('/blocking', (req, res) => {
    db.sequelize.query('CALL sp_users_blocking(:user_id)', {
        replacements: {
            user_id: req.body.user_id
        }
    }).then((data) => {
        res.json({ error: false, message: "Done!" });

    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.post('/forgot_password', (req, res) => {
    db.sequelize.query('CALL sp_users_forgot_password(:email, :code)', {
        replacements: {
            email: req.body.email,
            code: req.body.code
        }
    }).then(data => {
        let ret = data[0]["_ret"];
        if (ret === "invalid_email") {
            res.send({ error: true, message: `Invalid email '${req.body.email}'!` });
        } else if (ret === "account_inactive") {
            res.send({ error: true, message: `Account is flag inactive!` });
        } else if (ret === "invalid_code") {
            res.send({ error: true, message: `Invalid Code!` });
        } else if (ret === "success_request") {
            let code = data[0]["_code"];
            // send email
            let email_content = `Your GrandTCondoConnect password reset code: ${code}`;
            const respo = db.emailRequest({
                to: req.body.email,
                subject: "Reset Password Code",
                text: email_content,
            });
            res.json({ error: false, message: "Password reset code successfully send.", respo });
        } else if (ret === "success_verify") {
            res.json({ error: false, message: "Code successfully verified." });
        }
        else {
            res.send({ error: true, message: `Unknown Error!` });
        }

    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.get('/get_user_units', (req, res) => {
    db.sequelize.query('CALL sp_users_unit_get(:user_id)', {
        type: db.sequelize.QueryTypes.SELECT,
        replacements: {
            user_id: req.query.user_id
        }
    }).then((data) => {
        if (data) {
            res.json({ error: false, data: db.MultiQueryResult(data), message: "Done!" });
        } else {
            res.send({ error: true, message: 'No units data found!' });
        }
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

users.get('/get_user_privileges', (req, res) => {
    db.sequelize.query('CALL sp_users_privileges_get(:user_id)', {
        type: db.sequelize.QueryTypes.SELECT,
        replacements: {
            user_id: req.query.user_id
        }
    }).then((data) => {
        res.json({ error: false, data: db.MultiQueryResult(data), message: "Done!" });
    }).catch(err => {
        res.send({ error: true, message: `Error 767: ${err}` });
    });
});

module.exports = users;