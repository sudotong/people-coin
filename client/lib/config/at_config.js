/**
 * Created by sudot on 1/7/2018.
 */


AccountsTemplates.configure({
    defaultLayout: 'layout_main',

    // Behavior
    forbidClientAccountCreation: false,
    sendVerificationEmail: false,

    // Appearance
    showAddRemoveServices: false,
    showForgotPasswordLink: false,
    showLabels: true,
    showPlaceholders: false,
    showResendVerificationEmailLink: false,

    // Privacy Policy and Terms of Use
    privacyUrl: 'privacy',
    termsUrl: 'terms-of-use',

    // Texts
    texts: {
        button: {
            signUp: "Register Now!"
        },
        socialSignUp: "Register",
        socialIcons: {
            "meteor-developer": "fa fa-rocket"
        },
        title: {
            forgotPwd: "Recover Your Password"
        }
    }
});