/// From Firebase
const String ERROR_INVALID_EMAIL = 'ERROR_INVALID_EMAIL';
const String ERROR_USER_NOT_FOUND = 'ERROR_USER_NOT_FOUND';
const String ERROR_WRONG_PASSWORD = 'ERROR_WRONG_PASSWORD';
const String AUTH_INVALID_EMAIL = 'auth/invalid-email';
const String AUTH_INVALID_PASSWORD = 'auth/invalid-password';
const String AUTH_INVALID_PHONE_NUMBER = 'auth/invalid-phone-number';
const String AUTH_PHONE_NUMBER_ALREADY_EXIST =
    'auth/phone-number-already-exists';

const String ERROR_INVALID_CUSTOM_TOKEN = 'INVALID_CUSTOM_TOKEN';
const String ERROR_CUSTOM_TOKEN_MISMATCH = 'CUSTOM_TOKEN_MISMATCH';
const String ERROR_INVALID_CREDENTIAL = 'INVALID_CREDENTIAL';
const String ERROR_USER_MISMATCH = 'USER_MISMATCH';
const String ERROR_REQUIRES_RECENT_LOGIN = 'REQUIRES_RECENT_LOGIN';
const String ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL =
    'ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL';
const String ERROR_EMAIL_ALREADY_IN_USE = 'EMAIL_ALREADY_IN_USE';
const String ERROR_CREDENTIAL_ALREADY_IN_USE = 'CREDENTIAL_ALREADY_IN_USE';
const String ERROR_USER_DISABLED = 'USER_DISABLED';
const String ERROR_USER_TOKEN_EXPIRED = 'USER_TOKEN_EXPIRED';
const String ERROR_INVALID_USER_TOKEN = 'INVALID_USER_TOKEN';
const String ERROR_OPERATION_NOT_ALLOWED = 'OPERATION_NOT_ALLOWED';
const String ERROR_WEAK_PASSWORD = 'ERROR_WEAK_PASSWORD';

/// Firebase Auth 에 사용자가 존재하지 않는 경우 에러 메시지
const String AUTH_USER_NOT_FOUND = 'auth/user-not-found';

/// Firebase Auth 에는 존재하지만, Firestore 에 존재하지 않는 경우 에러 메시지
const String USER_NOT_EXIST = 'flutterbase/user-not-exist';

/// From Flutterbase
///
const String INVALID_PARAMETER = 'flutterbase/invalid-parameter';
const String INPUT_IS_EMPTY = 'flutterbase/input-is-empty';
const String FAILED_TO_REGISTER = 'flutterbase/failed-to-register';
const String EMAIL_IS_EMPTY = 'flutterbase/email-is-empty';
const String PASSWORD_IS_EMPTY = 'flutterbase/password-is-empty';
const String DISPLAYNAME_IS_EMPTY = 'flutterbase/displayname-is-empty';
const String ID_IS_EMPTY = 'id-is-empty';
const String CATEGORY_IS_EMPTY = 'flutterbase/category-is-empty';
const String FIALED_TO_GET_COMMENT = 'flutterbase/failed-to-get-comment';

/// App/Model Error code
const String INPUT_EMAIL = 'input_email';
const String INPUT_PASSWORD = 'input_password';
const String ERROR_USER_IS_NULL = 'user_is_null';
const String LOGIN_FIRST = 'login_first';
const String EMAIL_CANNOT_BY_CHANGED = 'email-cannot-be-changed';

const String ALREADY_LOGIN_ON_REGISTER_PAGE = 'already_login_on_register_page';

const String DELETED_PHOTO = 'https://userphoto.org/deleted.png';

const String POST_TITLE_DELETED = 'post-title-deleted';
const String POST_CONTENT_DELETED = 'post-content-deleted';
const String COMMENT_CONTENT_DELETED = 'comment-content-deleted';
const String NO_TITLE = 'no title';
const String ALREADY_DELETED = 'already deleted';
const String NOT_MINE = 'not mine';
const String CANNOT_VOTE_ON_MINE = 'cannot-post-on-mine';

const String ERROR_CAMERA_PERMISSION = 'permission-error-no-access-to-camera';

const String ADMIN_PAGE = 'admin dashboard';

const String CONFIRM_POST_DELETE_TITLE = 'confirm post delete title';
const String CONFIRM_POST_DELETE_CONTENT = 'confirm post delete content';

const String CONFIRM_COMMENT_DELETE_TITLE = 'confirm comment delete title';
const String CONFIRM_COMMENT_DELETE_CONTENT = 'confirm comment delete content';

const String CONFIRM_CATEGORY_DELETE_TITLE = 'confirm category delete title';
const String CONFIRM_CATEGORY_DELETE_CONTENT =
    'confirm category delete content';

const String CREATE_POST = 'create post';
const String UPDATE_POST = 'update post';
const String CREATE_CATEGORY = 'create category';
const String UPDATE_CATEGORY = 'update category';
const String DELETE_CATEGORY = 'delete category';

const String BIRTHDAY_8_DIGITS = 'birthday 8 digits';
const String SHOW_DATE_PICKER = 'show date picker';
const String POST_CREATE = 'post create';

const String PERMISSION_DENIED = 'permission denied';


const String UPDATE_PROFILE = 'update-profile';
const String UPDATE_PROFILE_BUTTON = 'update-profile-button';
const String REGISTER_BUTTON = 'register-button';
const String PROFILE_UPDATE_TITLE = 'profile-update-title';
const String REGISTER_TITLE = 'register-title';

const String APP_TITLE = 'app-title';


const String LOGIN_BUTTON = 'login-button';
const String LOST_PASSWORD_BUTTON = 'lost-password-button';
const String OR_LOGIN_WITH = 'or-login-with';


/// @see README
class EngineRoutes {
  static final String postList = 'postList';
}

const String CACHE_VERSION = '1';
const String CACHE_BOX = 'flutterbasecache';

class EngineCacheKey {
  static String forumList(String id) {
    return id + '-forum-list-' + CACHE_VERSION;
  }

  static String frontPage(String id) {
    return id + '-front-page-' + CACHE_VERSION;
  }
}
