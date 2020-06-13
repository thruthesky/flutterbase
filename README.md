# Flutterbase

* 명칭: Flutterbase
* 라이센스: GPL 3.0
* 개발자: 송재호 thruthesky@gmail.com

## 개요

* 모든 앱에서 회원 가입 및 회원 정보 관리, 그리고 게시판 기능이 필요하죠.
  * 이를 CMS(Content Management System)이라고 합니다.
* 본 프로젝트에서는 플러터와 파이어베이스를 기본으로 하는 CMS 를 재 사용이 쉽도록 모듈화 하여, 복사해서 쓸 수 있도록 해 놓았습니다.
* 게시판 기능을 수정하여 블로그나 쇼핑몰 등 다양하게 활용 할 수 있습니다.
* 특정 앱에 종속되지 않는 독립된 모듈로서 동작하여 어떤 앱에서도 사용 될 수 있습니다.

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

### Firebase 설정

* Firestore 를 생성하고 [Flutterbase Rules](https://github.com/thruthesky/flutterbase-security-test/blob/master/firestore.rules) 를 적용합니다.



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



* Sign-in Method 지정

  * Email/Password
  * Anonymous
  * Google

와 같이 Enable 합니다.

* Storage 를 생성(또는 준비)합니다.
  * 참고: Storage 의 경우 권한 지정이 로그인 사용자로 지정되는데, 권한 지정이 좀 더 세밀하게 지정될 필요가 있습니다. 이 부분은 현재 [Issue](https://github.com/thruthesky/flutterbase/issues/3) 로 생성되어져 있습니다.



### 새로운 프로젝트를 시작하려는 경우,

* 만약, 새로운 프로젝트를 시작하려 할 때, [Flutter CMS](https://github.com/thruthesky/fluttercms/)를 fork (또는 clone)한 다음 수정해서 사용하는 것도 좋은 방법입니다.

* `Flutter CMS` 를 fork (또는 clone) 에서 대해서는 [Flutter CMS](https://github.com/thruthesky/fluttercms/)의 README 문서를 참고해주세요.



### 기존에 존재하는 프로젝트에 설정하는 경우


#### Flutterbaes 추가

* 먼저, `Flutterbase` 를 다운로드하여, `lib/flutterbase` 폴더에 추가합니다.
  * `git clone https://github.com/thruthesky/flutterbase lib/flutterbase`


#### Flutter 에 Android, iOS 앱 설정

* 파이어베이스 프로젝트에서 iOS 앱을 추가하고, iOS 에 설정을 합니다.
* 파이어베이스 프로젝트에서 Android 앱을 추가하고, Android 설정을 합니다.


#### 프로젝트 설정

* 그리고 프로젝트 루트 폴더에 `settigns.dart` 를 생성하고 `storageLink` 를 설정합니다.
  * 참고: [FlutterCMS settings.dart](https://github.com/thruthesky/fluttercms/blob/master/lib/settings.dart)

* 프로젝트에 필요한 패키지들을 pubspec.yaml 에 추가합니다.
  * 참고: [FlutterCMS pubspec.yaml](https://github.com/thruthesky/fluttercms/blob/master/pubspec.yaml) 에서 Dependency 를 복사하면 됩니다.

  * 사용자 아이콘을 pubspec.yaml 에 등록합니다.

```
  assets:    
    - lib/flutterbase/assets/images/user-icon.png
```

* 아래와 같이 iOS의 Info.plist 에서 권한 문자열 지정 하시면 됩니다.

```
	<key>NSCameraUsageDescription</key>
	<string>This app requires access to the Camera to take images for posting on its forum and updating user profile.</string>
	<key>NSContactsUsageDescription</key>
	<string>This app requires access to the Contact.</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>This app requires access to the microphone.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>This app requires access to the Photo Library to display images</string>
```

참고: [FlutterCMS Info.plist](https://github.com/thruthesky/fluttercms/blob/master/ios/Runner/Info.plist) 에서 `XXXXXDescription` 복사
  
##### 다국어 설정

* 다국어 언어 설정
  * Info.plist 에 아래와 같이 추가하면 됩니다.
  * 참고: [FlutterCMS Info.plist](https://github.com/thruthesky/fluttercms/blob/master/ios/Runner/Info.plist) 

```
<key>CFBundleLocalizations</key>
<array>
	<string>en</string>
	<string>ko</string>
	<string>ja</string>
	<string>zh</string>
</array>
```

#### 관리자 설정

* 관리자 지정하기
  * 사용자 도큐먼트에서 `isAdmin` 속성을 true 로 주면 관리자가 됩니다.
  * 예) `users/user-id/{ ..., isAdmin: true }`
  * 참고
    * Firestore 에서 Document Filtering(검색) 기능을 통해서, 검색하면 된다. Document 필드 중 email 또는 uid 이 없다면, displayName 으로 검색하면 됩니다.
    * 먼저 앱을 실행하고, 회원 가입을 한 다음, 그 회원의 user document 를 수정하는 것이 편합니다.


#### 카테고리 설정

* 게시판 카테고리 생성
  * 관리자 지정 후, 다시 로그인을 하면, 메뉴에서 관리자 페이지로 진입 할 수 있습니다.
  * 기본적으로 `discussion`, `qna` 두 개의 카테고리를 생성하면 됩니다.





## 테스트

### Security Rule Test

* Firestore 권한에 대한 테스트 코드를 작성하였습니다.
  * [Flutterbase Security Test](https://github.com/thruthesky/flutterbase-security-test) 를 참고.
  * `Flutterbase` 의 dart 코드는 mocking 을 하지 않아도, 테스트 할 수 있는 방법이 있지만,
  * `Firestore Security Test`에서는 mocking 말고는 방법이 없습니다. 그래서 mocking 으로 권한 테스트합니다.




## 수정

* 설치가 끝났으면 실제 코드 작성하면 됩니다.
* 필요한 부분을 복사해서 사용하시면 됩니다.


### 모델

* Flutterbase 모델을 main.dart 에서 Provide 한다.
* 


### 라우팅

* 라우팅은 원하시는데로 하면 되지만, [Flutter CMS](https://github.com/thruthesky/fluttercms/) 예제에서는 Named Router 를 사용합니다.


* Flutter CMS 의 라우팅 예제를 보시면 이해를 하는데 도움이 될 것입니다.
  * [Flutter CMS Routing Definitions](https://github.com/thruthesky/fluttercms/blob/master/lib/services/app.defines.dart)
  * [Flutter CMS Routing](https://github.com/thruthesky/fluttercms/blob/master/lib/services/app.router.dart)


### App Bar

* FlutterbaseAppBar 위젯이 있는데, 이를 복사해서 쓰거나 그대로 쓰면 됩니다.

### 회원 기능

* 먼저, [Flutter CMS 회원 가입 페이지](https://github.com/thruthesky/fluttercms/blob/master/lib/pages/register/register.page.dart)에서 코드를 복사해서, 회원 가입을 하면 됩니다.

* 그리고, [Flutter CMS 회원 로그인 페이지](https://github.com/thruthesky/fluttercms/blob/master/lib/pages/login/login.page.dart)에서 로그인을 하면 됩니다.

* 사진 업로드
  * 회원 가입 또는 수정에서 사진을 업로드 할 수 있으며, 타이틀 바에 사진을 표시 할 수 있습니다.

### 게시판 기능

* 게시글 목록
* 게시글 작성
* 게시글 수정
* 코멘트 작성
* 코멘트 수정





## 개발자 팁

### Spinner

* 처리 중 spinner 보여 줄 때, state 내에서 변수 정의 하고, state 업데이트 하는 등 번거로운 점이 있다.
* spinner 변수를 모델이나 해당 객체(글 또는 코멘트 도큐먼트)에 저장해서 처리를 한다.
* 즉, 해당 작업을 처리하는 함수 안에서 표시를 하도록 해서, 개벌 클래스 내에서는 코드를 줄인다.

예를 들어

* showSpinner: inDeleting 과 같이 true, false 에 따라 spinner 를 보여준다면,
* fb.delete(post); 와 같이 호출 할 때,
* delete() 안에서 post.inDeleting = true 하고, 작업이 끝나면 post.inDeleting = false 한다.


### 삭제된 글 처리

* 삭제 된 글을 삭제해도 글은 그냥 삭제가 된 것이다.
* 또한 삭제된 글을 수정해도 이미 deletedAt 에 값이 있기 때문에 이미 삭제된 것이다.

* 삭제 된 글을 삭제, 추천 할 때에는 해당 작업 처리 함수에서 에러를 throw 하도록 한다.

* 하지만, 삭제된 글은 수정 할 때에는, 수정 작업 함수가, 사용자가 글을 다 수정한 후, 버튼을 클릭하면 발생하기 때문에, 사용자가 불편함을 겪게 된다. 따라서
  * 수정 버튼을 없애거나
  * disable 시키거나
  * 또는 최소한 삭제가 되었으면 수정 버튼을 클릭 할 때 삭되었다고 알려준다.


### 추천/비추천

* 도큐먼트를 생성할 때, like 와 dislike 의 값을 0 으로 초기화 해야 한다. 그렇지 않으면, security rule 이나 기타 작업에서 번거로운 점이 많다.
  * security rules 에서 rule 로 정한다.