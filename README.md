# Codex Ne Kadar

Codex kullanım limitlerini macOS menü çubuğunda gösteren küçük, yerel ve açık kaynak bir uygulama.

- Kısa ve uzun limit pencerelerinin kalan yüzdesini canlı gösterir.
- Sıfırlanma zamanlarını geri sayım olarak sunar.
- Seçtiğiniz eşiklerde (`%50, %25, %10` gibi) yerel bildirim gönderir.
- Kişisel bilgi içermeyen kullanım özetini tek tıklamayla panoya kopyalar.
- İsteğe bağlı olarak macOS açılışında otomatik başlar.

> Bu proje OpenAI tarafından yayımlanan resmî bir uygulama değildir. Codex'in yerel arayüzündeki değişiklikler uygulamanın çalışmasını etkileyebilir.

## Gereksinimler

- macOS 13 veya üzeri
- Apple Silicon Mac
- ChatGPT veya Codex masaüstü uygulamasında açık bir ChatGPT oturumu

## Kurulum

### Hazır sürüm

1. GitHub sayfasındaki **Releases** bölümünden son `.zip` dosyasını indirin.
2. Arşivi açıp `Codex Ne Kadar.app` dosyasını `/Applications` klasörüne taşıyın.
3. Uygulamayı Finder'da sağ tıklayıp **Aç** seçeneğiyle başlatın.

Uygulama ad-hoc imzalıdır; ilk açılışta macOS geliştirici doğrulama uyarısı gösterebilir.

### Kaynaktan

```zsh
git clone https://github.com/gurursonmez90/codex-ne-kadar.git
cd codex-ne-kadar
./scripts/build-app.sh
open "dist/Codex Ne Kadar.app"
```

Derlenen uygulama `dist/Codex Ne Kadar.app` yolunda oluşur. Tam Xcode kurulumu gerekmez; macOS Command Line Tools ve Swift 6 yeterlidir.

## Kullanım

1. Menü çubuğundaki canlı yüzde çiftine tıklayın.
2. Panelden limitleri ve sıfırlanma sürelerini izleyin.
3. **Kopyala** ile e-posta adresi içermeyen kullanım özetini panoya alın.
4. **Ayarlar** bölümünden bildirimleri, eşikleri, güncelleme sıklığını ve girişte başlatmayı yönetin.

Uygulama ilk çalıştırmada macOS giriş öğelerine otomatik kaydolur. Menü çubuğundaki sayacı taşımak için `⌘ Command` tuşunu basılı tutup sürükleyin. macOS seçtiğiniz konumu sonraki açılışlarda korur; üçüncü taraf uygulamalar Denetim Merkezi ve saat gibi sistem simgelerinin sağına yerleştirilemez.

Her uyarı; limit penceresi, eşik ve sıfırlanma döngüsü başına yalnızca bir kez gönderilir. İlk okuma başlangıç değeri olarak alınır, dolayısıyla uygulama açılır açılmaz geçmiş kullanım için bildirim yağdırmaz.

## Ekran görüntüsü ekleme

1. Ekran görüntüsünü `docs/screenshots/main.png` olarak kaydedin.
2. Kişisel e-posta adresi veya başka hassas bilgi görünmediğini kontrol edin.
3. Bu README'de uygun yere şu satırı ekleyin:

```md
![Codex Ne Kadar ana paneli](docs/screenshots/main.png)
```

4. Görseli commit'e ekleyip GitHub'a gönderin:

```zsh
git add docs/screenshots/main.png README.md
git commit -m "Add app screenshot"
git push
```

GitHub, depodaki göreli görsel yolunu README içinde otomatik olarak gösterir. Retina PNG dosyasını mümkünse 1 MB altında tutmak depo boyutunu makul seviyede tutar.

## Gizlilik ve teknik yaklaşım

Uygulama token veya `auth.json` okumaz ve ağ isteğini kendisi yapmaz. Kurulu ChatGPT/Codex uygulamasının yerel `codex app-server` arayüzü üzerinden `account/rateLimits/read` çağrısını kullanır. Pencere adları sabit kodlanmaz; süre ve sıfırlanma zamanı Codex yanıtından gelir. Veriler yalnızca cihaz üzerinde gösterilir.

ChatGPT/Codex uygulaması bulunamazsa menü panelinde açıklayıcı bir hata gösterilir.

## Geliştirme ve doğrulama

```zsh
swift build --jobs 1
.build/debug/CodexNeKadar --self-test
./scripts/build-app.sh
```

Pull request ve hata bildirimleri memnuniyetle karşılanır. Hata bildirirken macOS ve Codex sürümünü yazın; günlüklerdeki e-posta, token veya hesap bilgilerini paylaşmayın.
