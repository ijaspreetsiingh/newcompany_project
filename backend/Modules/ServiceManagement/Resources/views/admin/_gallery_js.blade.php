
        /* Gallery Image block - multi file preview + new image remove */
        $(document).ready(function() {
            $('#galleryInput').on('change', function(e) {
                const preview = document.getElementById('galleryPreviewWrap');
                if (!preview) return;
                [...e.target.files].forEach(file => {
                    const reader = new FileReader();
                    reader.onload = function (ev) {
                        const div = document.createElement('div');
                        div.className = 'col-md-2 col-4 gallery-item position-relative gallery-new-item';
                        div.innerHTML = `<img src="${ev.target.result}" class="w-100 rounded border" style="height:120px;object-fit:cover" alt="gallery">
                            <button type="button" class="btn btn-sm btn-danger position-absolute" style="top:4px;right:4px;padding:0 6px;line-height:1.4"
                                onclick="this.closest('.gallery-item').remove()">&times;</button>`;
                        preview.appendChild(div);
                    };
                    reader.readAsDataURL(file);
                });
            });
        });
