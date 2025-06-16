
# Track Supreme

![Track Supreme Logo](assets/images/logo.png)  
*Track Supreme uygulamasının logosu*


## Giriş

Track Supreme, kullanıcıların e-posta, Google veya GitHub hesaplarıyla kolayca giriş yaparak kargo takip numaralarını tek bir uygulamada yönetebileceği modern ve güvenli bir platformdur. Anlık kargo durumu güncellemeleri ile kargolarınızı her an takip edebilirsiniz.


## Özellikler

| ![Ana Ekran](assets/images/home_screen.png) | ![Profil Sayfası](assets/images/profile_screen.png) |
|:------------------------------------------:|:-------------------------------------------------:|
| *Kargo takip ana ekranı*                    | *Kullanıcı profil ve ayarları*                     |

- Çoklu giriş desteği: E-posta, Google, GitHub  
- Gerçek zamanlı kargo takibi  
- Profil resmi yükleme ve kişisel bilgileri güncelleme  
- Drawer menüsü ile hızlı navigasyon  
- Farklı kargo firmalarının tek bir uygulamada takibi  
- Lokal önbellekleme ile offline kullanım (SQLite opsiyonel)



## Teknolojiler

![Flutter](assets/images/technologies/flutter.png) ![Firebase](assets/images/technologies/firebase.png) ![Supabase](assets/images/technologies/supabase.png) ![Google Cloud](assets/images/technologies/google_cloud.png)

- **Flutter & Dart:** Platformlar arası geliştirme  
- **Firebase:** Authentication, Firestore, Cloud Functions  
- **Supabase:** Kullanıcı profili ve veri yönetimi  
- **Google Cloud:** API yönetimi ve arka plan servisleri  
- **REST API & JSON:** Kargo takip verisi aktarımı  
- **SQLite (opsiyonel):** Lokal önbellekleme ve performans artışı
- **SharedPreferences:**   Küçük verilerin (ayarlar, tercihler vb.) cihazda kalıcı olarak saklanması için kullanılır.



## Kurulum ve Çalıştırma

1. Projeyi klonlayın:  
    ```bash
    git clone https://github.com/yourusername/track-supreme.git
    cd track-supreme
    ```
2. Gerekli paketleri yükleyin:  
    ```bash
    flutter pub get
    ```
3. Firebase ve Supabase yapılandırmalarını yapın (config dosyalarını düzenleyin).  
4. Web platformunda sabit port ile çalıştırmak için:  
    ```bash
    flutter run -d chrome --web-port=5000
    ```
5. Uygulamayı başlatın:  
    ```bash
    flutter run
    ```

---

## Kullanım Kılavuzu

### Giriş Yapma  
![Giriş Ekranı](assets/images/login_screen.png)  
- E-posta, Google veya GitHub ile hızlı ve güvenli giriş yapabilirsiniz.

### Kargo Takip  
![Kargo Takip](assets/images/track_package.png)  
- Takip numarası ekleyip anlık kargo durumunuzu görüntüleyebilirsiniz.

### Profil Yönetimi  
![Profil Düzenleme](assets/images/profile_edit.png)  
- İsim, e-posta ve profil resminizi kolayca güncelleyebilirsiniz.

---

## Katkıda Bulunanlar

| İsim          | Rol                | Sorumluluklar                       |
|---------------|--------------------|-----------------------------------|
| Emad | Frontend & API     | UI tasarımı, temel işlevsellik    |
| Mohamed Abdulla Elfaituri | Backend & Optimizasyon | Gelişmiş özellikler, güvenlik    |

---

## Gelecek Özellikler

- Firebase Cloud Functions ile otomatik güncellemeler  
- Supabase ile gelişmiş profil senkronizasyonu  
- Gelişmiş hata yönetimi  
- API limit ve hata tolerans mekanizmaları  
- Push notification entegrasyonu  
- UI/UX iyileştirmeleri ve animasyonlar  

---

## Lisans

MIT Lisansı altında lisanslanmıştır. (İsterseniz değiştirebilirsiniz.)

---

