# pdf2cbz

Convierte uno o múltiples archivos PDF en archivos CBZ optimizados para lectura de manga/comics.

## 📦 Requisitos

- poppler (`pdftoppm`)
- zip

En Arch Linux:

```bash
sudo pacman -S poppler zip
```

## 🚀 Uso

Convertir un solo archivo:

```bash
pdf2cbz archivo.pdf
```

Convertir múltiples:

```bash
pdf2cbz *.pdf
```

## ⚙️ Qué hace

- Convierte PDF a imágenes JPEG (150 DPI)
- Renombra páginas en orden (`001.jpg`, `002.jpg`, ...)
- Crea archivo `.cbz`
- Elimina el PDF original (si está configurado)
- Limpia archivos temporales

## 📂 Instalación manual

```bash
sudo cp pdf2cbz.sh /usr/local/bin/pdf2cbz
sudo chmod +x /usr/local/bin/pdf2cbz
```

---

Autor: Alfredo Ramírez Candia
