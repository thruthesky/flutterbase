const WRONG_CLASS_NAME = 'engin/wrong-class-name';
const WRONG_METHOD_NAME = 'engin/wrong-method-name';

/// From Firebase
const String ERROR_INVALID_EMAIL = 'error_invalid_email';
const String ERROR_USER_NOT_FOUND = 'error_user_not_found';
const String ERROR_WRONG_PASSWORD = 'error_wrong_password';
const String AUTH_INVALID_EMAIL = 'auth/invalid-email';
const String AUTH_INVALID_PASSWORD = 'auth/invalid-password';
const String AUTH_INVALID_PHONE_NUMBER = 'auth/invalid-phone-number';
const String AUTH_PHONE_NUMBER_ALREADY_EXIST =
    'auth/phone-number-already-exists';

/// Firebase Auth 에 사용자가 존재하지 않는 경우 에러 메시지
const String AUTH_USER_NOT_FOUND = 'auth/user-not-found';

/// Firebase Auth 에는 존재하지만, Firestore 에 존재하지 않는 경우 에러 메시지
const String USER_NOT_EXIST = 'engin/user-not-exist';

/// From Enginf (Backend, Cloud Functions)
const String EMAIL_IS_NOT_PROVIDED = 'engin/email-is-not-provided';
const String PASSWORD_IS_NOT_PROVIDED = 'engin/password-is-not-provided';

/// App/Model Error code
const String INPUT_EMAIL = 'input_email';
const String INPUT_PASSWORD = 'input_password';
const String ERROR_USER_IS_NULL = 'user_is_null';
const String LOGIN_FIRST = 'login_first';

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

const String CREATE_POST = 'create post';
const String UPDATE_POST = 'update post';
const String CREATE_CATEGORY = 'create category';
const String UPDATE_CATEGORY = 'update category';
const String DELETE_CATEGORY = 'delete category';

const String BIRTHDAY_8_DIGITS = 'birthday 8 digits';
const String SHOW_DATE_PICKER = 'show date picker';
const String POST_CREATE = 'post create';



/// @see README
class EngineRoutes {
  static final String postList = 'postList';
}


const String CACHE_VERSION = '1';

class EngineCacheKey {
  static String forumList(String id) {
    return id + '-forum-list-' + CACHE_VERSION;
  }
  static String frontPage(String id) {
    return id + '-front-page-' + CACHE_VERSION;
  }
}