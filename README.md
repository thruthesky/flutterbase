# Flutterbase

* 명칭: Flutterbase
* 라이센스: GPL 3.0
* 개발자: 송재호 thruthesky@gmail.com

## 개요

* 모든 앱에서 회원 가입 및 회원 정보 관리, 그리고 게시판 기능이 필요하죠.
  * 이를 CMS(Content Management System)이라고 합니다.
* 본 프로젝트에서는 플러터와 파이어베이스를 기본으로 하는 CMS 를 재 사용이 쉽도록 모듈화 하여, 복사해서 쓸 수 있도록 해 놓았습니다.
* 게시판 기능을 수정하여 블로그나 쇼핑몰 등 다양하게 활용 할 수 있습니다.

### 유료 서비스 안내

* 본 프로젝트는 오픈 소스이지만 사용함에 있어 어려운 경우 유료 서비스를 요청 하실 수도 있습니다.
  * 설치가 어려운 경우
    * Firebase 설정 및 앱 설정을 해 드립니다.
  * 추가 기능이 필요한 경우
    * Flutter CMS 가 가진 기본 기능 외에 추가 기능이 필요 한 경우 개발을 해 드립니다.
* 연락처: thruthesky@gmail.com

## 참고

* Flutterbase 로 만든 [FlutterCMS](https://github.com/thruthesky/fluttercms) 예제 참고



## 설치

* Flutter 앱에 `Flutterbase` 를 추가하는 경우를 설명합니다.


* 먼저, `Flutterbase` 를 다운로드하여, `lib/flutterbase` 폴더에 추가합니다.
  * `git clone https://github.com/thruthesky/flutterbase lib/flutterbase`

* 파이어베이스 프로젝트에서 iOS 앱을 추가하고, iOS 에 설정을 합니다.
* 파이어베이스 프로젝트에서 Android 앱을 추가하고, Android 설정을 합니다.

* Firestore 를 생성하고 다음의 Rules 를 적용합니다.

``` js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {


    // 기본적으로 모든 읽기와 쓰기를 막는다.
    match /{document=**} {
      allow read: if false;
      allow write: if false;
    }
    // 사용자
    match /users/{uid} {
      // 로그인을 했으면, 도큐먼트 생성 가능
      allow create: if login();

      // 자신의 도큐먼트이면 읽기 가능.
      allow read: if request.auth.uid == uid;

      // 자신의 도큐먼트인 경우, `isAdmin` 속성은 빼고 수정 가능.
      // 관리자인 경우에도, request data 로 직접 isAmdin 속성을 수정 할 수 없다. 
      allow update: if request.auth.uid == uid && notUpdating('isAdmin');

      // 삭제는 불가능
      allow delete: if false;
    }

    // 카테고리. 모든 회원이 읽을 수 있지만, 관리자만 쓰기 가능.
    match /categories/{category} {
      allow read: if true;
      allow create, delete: if admin();
      allow update: if admin() && notUpdating('id');
    }

    // 글
    match /posts/{postId} {
      // 아무나 글을 읽거나 목록 할 수 있음.
      allow read: if true;


      // 생성
      // - 로그인을 했으면, 도큐먼트 생성 가능
      // - 글 쓰기/수정에서 카테고리가 있어야 하며 존재 해야 함.
      allow create: if login()
        && toBeMyDocument()
        && categoryExist()
        && mustBeZero('like')
        && mustBeZero('dislike');



      // 수정
      //
      // 필수 입력: 없음??
      
      // 
      // 
      // - 수정은 자기 글만 가능
      // - uid 변경 불가
      // - 카테고리가 존재해야 함
      //
      // - 다른 사람이 내 글을 수정하는 경우, 오직 'like' 와 'dislke' 만 수정 가능하다. 
      // - 자신 뿐만아니라 타인이 vote 할 수 있다.
      allow update: if
      (
        myDocument() 
        && categoryExist()
        && notUpdating('uid')
      )
      || 
      ( 
        // 본인 뿐만 아니라 타인도 이 rule 로 vote
        onlyUpdating(['like', 'dislike']) 
        && updatingByOne('like') 
        && updatingByOne('dislike')
        )
      ;


      // 삭제는 자기 글만 가능
      //
      // 필수 입력: 없음.
      allow delete: if myDocument();


      // 코멘트
      // - 각 글 도큐먼트 하위에 기록
      match /comments/{comment} {
        allow read: if true;

        // 코멘트 생성 권한
        // - 입력값: uid, content, depth, order. `post id` 는 필요 없음.
        allow create: if login() && toBeMyDocument() // 내 코멘트이어야 하고
          && exists(/databases/$(database)/documents/posts/$(postId)) // 글이 존재해야 하고
          && request.resource.data.order is string // order 가 문자열로 들어와야 하고,
          && request.resource.data.order.size() == 71 // order 가 71 글자 길이어야 한다.
          && request.resource.data.depth is number // order 가 number 로 들어와야 하고,
          && request.resource.data.depth > 0 && request.resource.data.depth <= 12 // 1 부터 12 사이의 값이어야 한다.
          && mustBeZero('like') && mustBeZero('dislike')
          ;

        // 코멘트 수정 권한
        // - 내 코멘트이고,
        // - `uid`, `order` 를 업데이트 하지 않아야 한다.
        // - 자신 뿐만아니라 타인이 vote 할 수 있다.
        allow update: if
          (
            login()
            && toBeMyDocument() 
            && notUpdating('uid')
            && notUpdating('order')
          )
          ||
          (
          // 본인 뿐만 아니라 타인도 이 rule 로 vote
            onlyUpdating(['like', 'dislike'])
            && updatingByOne('like')
            && updatingByOne('dislike')
          )
          ;

        // 코멘트 삭제 권한
        // - 내 코멘트이면 삭제 가능
        allow delete: if login() && myDocument();
      }
    }



    // 추천/비추천
    match /likes/{like} {
      // 읽기는 로그인만 하면 된다.
      // 타인의 likes 정보를 읽을 수 있다. 별 중요한 정보가 아니다.
      // 굳이, 존재하지 않으면, 통과 && Documennt 가 존재하면 내 글인지 확인 할 필요가 없다.
      allow read: if login();
      allow create: if login() && toBeMyDocument() && request.resource.data.keys().hasOnly(['uid', 'id', 'vote']);
      allow update: if login() && myDocument() && notUpdating('uid') && request.resource.data.keys().hasOnly(['uid', 'id', 'vote']);
      allow delete: if login() && myDocument();
    }
    

    // 설정. 모든 회원이 읽을 수 있지만, 관리자만 쓰기 가능.
    match /settings/{document=**} {
      allow read: if true;
      allow write: if admin();
    }




    // 로그인을 했는지 검사
    //
    // Anonymous 로그인은 로그인하지 않은 것으로 간주.
    function login() {
      return request.auth.uid != null
        && ( request.auth.token.firebase.sign_in_provider != 'anonymous' );
    }

    // 필드를 변경하지 못하게 검사
    //
    // request data 에 field 가 없거나, 있다면, 저장되어져 있는 값과 동일해야 한다.
    // 즉, 값을 변경을 하지 못하도록 하는 체크하는 함수이다.
    function notUpdating(field) {
      return !(field in request.resource.data) || resource.data[field] == request.resource.data[field];
    }

    // request data 에 특정 field 가 있는지 검사한다.
    // function requestHas(field) {
    //   return field in request.resource.data;
    // }

    // 사용자의 uid 와 문서에 저장되어져 있는 uid 가 일치하면 본인의 데이터
    function myDocument() {
      return resource.data.uid == request.auth.uid;
    }

    // 사용자의 uid 와 저장할 데이터의 uid 가 일치하면, 나의 데이터로 저장 될 것이다.
    function toBeMyDocument() {
      return request.resource.data.uid == request.auth.uid;
    }

    // 관리자 인지 확인.
    //
    // 사용자 도큐먼트에 `isAdmin` 속성이 true 인 경우, 관리자로 간주한다.
    function admin() {
      return login() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    // 카테고리가 존재하는지 검사한다.
    // - `category` 에 category id 값이 들어와야 한다.
    function categoryExist() {
      return exists(/databases/$(database)/documents/categories/$(request.resource.data.category));
    }

    // 특정 값만 업데이트하는지 확인
    //
    // 예) onlyUpdating(['like', 'dislike']);
    function onlyUpdating(fields) {
      return request.resource.data.diff(resource.data).affectedKeys().hasOnly(fields);
    }

    // 특정 필드에 대한 증감 값 확인
    //
    // `field` 가 숫자인지 확인
    // `field` 가 업데이트되지 않거나 또는 최대 1 증가, 최소 1 감소하는지 확인.
    //
    // TODO: like/dislike 는 동시에 1이 증가하거나 동시에 1이 감소 할 수 없다. 하지만 큰 문제가 아니기 때문에 차 후 업데이트한다.
    function updatingByOne(field) {
      return request.resource.data[field] is int
        &&
        ( 
          request.resource.data[field] == resource.data[field] // 값이 변하지 않거나
          ||
          request.resource.data[field] == resource.data[field] + 1 // 값이  1 증가 하거나
          ||
          request.resource.data[field] == resource.data[field] - 1 // 값이  1 감소 하거나
        );
    }

    function mustBeZero(field) {
      return request.resource.data[field] is int && request.resource.data[field] == 0;
    }

    // 게시글이 존재하는지 검사한다.
    // 현재 액세스하려는 post document 가 실제로 존재하는 것인지 검사
    // function postExist() {
    //   return exists(/databases/$(database)/documents/posts/$(request.resource.data.postId));
    // }

  }


}
```

* Firestore 인덱스 지정하기

  * 아래의 Indexes 를 생성합니다.

```
Collection ID: posts
Fields Indexed: category Ascending createdAt Descending
Query Scope: Collection
```

* Index 를 생성하는 방법은 아래와 같이 세가지가 있습니다.
  * Firebase Console 에서 생성
  * Google Cloud Console 에서 생성
  * CLI 에서 생성

  위 세가지 방법 중 하나로 Index 를 생성합니다.


* 관리자 지정하기
  * 사용자 도큐먼트에서 `isAdmin` 속성을 true 로 주면 관리자가 됩니다.
  * 예) `users/user-id/{ ..., isAdmin: true }`
  * 참고로, Firestore 에서 Document Filtering(검색) 기능을 통해서, 검색하면 된다. Document 필드 중 email 또는 uid 이 없다면, displayName 으로 검색하면 됩니다.


* Sign-in Method 지정

  * Email/Password
  * Anonymous
  * Google

와 같이 Enable 한다.

* Storage 를 생성(또는 준비)합니다.
  * 참고: Storage 의 경우 권한 지정이 로그인 사용자로 지정되는데, 권한 지정이 좀 더 세밀하게 지정될 필요가 있습니다. 이 부분은 현재 [Issue](https://github.com/thruthesky/flutterbase/issues/3) 로 생성되어져 있습니다.

* 그리고 프로젝트 루트 폴더에 `settigns.dart` 를 생성하고 `storageLink` 를 설정합니다.
  * 참고: [FlutterCMS settings.dart](https://github.com/thruthesky/fluttercms/blob/master/lib/settings.dart)

* 프로젝트에 필요한 패키지들을 pubspec.yaml 에 추가합니다.
  * 참고: [FlutterCMS pubspec.yaml](https://github.com/thruthesky/fluttercms/blob/master/pubspec.yaml) 에서 Dependency 를 복사하면 됩니다.

* iOS의 Info.plist 에서 권한 문자열 지정 하시면 됩니다.
  * 참고: [FlutterCMS Info.plist](https://github.com/thruthesky/fluttercms/blob/master/ios/Runner/Info.plist) 에서 `XXXXXDescription` 들을 복사하면 됩니다.


* 다국어 언어 설정
  * Info.plist 에 아래와 같이 추가하면 됩니다.

```
<array>
  <string>en</string>
  <string>ko</string>
  <string>ja</string>
  <string>zh</string>
</array>
```


