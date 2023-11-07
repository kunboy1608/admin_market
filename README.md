<a name="readme-top"></a>
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://github.com/othneildrew/Best-README-Template/blob/master/images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Fruit Clients - Mobile - Flutter</h3>

  <p align="center">
    Developed by HoangDP
  </p>
</div>




<!-- ABOUT THE PROJECT -->
## About The Project

The situation is: A fruit shop has many loyal customers who prefer home delivery. With the advancement of technology and smartphones, the fruit shop owner wants to make a mobile app that allows customers to order products from his shop through their phones.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* Flutter 3.13.9
* Firebase: Auth, Firestore, Storage
* BloC
* See more details in pubspeck.yaml

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Screenshots

<img src="resource_readme/1.jpg" alt="1" width=200/> <img src="resource_readme/2.jpg" alt="2" width=200/> <img src="resource_readme/3.jpg" alt="3" width=200/> <img src="resource_readme/4.jpg" alt="4" width=200/>


<!-- Installation -->
## Installation

1. Go to <a href="https://console.firebase.google.com/">Firebase</a>,
2. Create Project
3. Create Firestore, config Rules below:
```
rules_version = '2';
// Allow read/write access on all documents to any user signed in to the application
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
4. In project settings add Android App. Then add SHA1 key. How to get SHA1 <a href="https://developers.google.com/android/guides/client-auth">here</a>
5. Download your file google-services.json and replace file android/app/google-services.json
6. Run project
```
flutter run --debug
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Phu Hoang - kunboy1608@gmail.com

Project Link: [https://github.com/kunboy1608/todo-app/](https://github.com/kunboy1608/todo-app/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/phu-hoang-046993236/
[product-screenshot]: images/open-api-3-user.png

