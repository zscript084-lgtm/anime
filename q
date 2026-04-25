

Copy
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AniStream Live</title>
    <style>
        :root {
            --primary: #ff4757;
            --dark: #0f1115;
            --dark-card: #1a1d24;
            --text: #ffffff;
            --text-gray: #a0a0a0;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: var(--dark); color: var(--text); overflow-x: hidden; }
        header { background: rgba(15, 17, 21, 0.95); padding: 20px 40px; position: sticky; top: 0; z-index: 100; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #2a2d35; }
        .logo { font-size: 24px; font-weight: bold; color: var(--primary); text-decoration: none; letter-spacing: 1px; }
        .search-box { background: #2a2d35; padding: 10px 20px; border-radius: 50px; display: flex; align-items: center; width: 300px; }
        .search-box input { background: transparent; border: none; color: white; width: 100%; outline: none; margin-left: 10px; }
        main { padding: 40px; max-width: 1400px; margin: 0 auto; }
        .hero { height: 40vh; background: linear-gradient(to top, var(--dark), transparent), url('https://images.unsplash.com/photo-1578632749831-574848846535?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80'); background-size: cover; background-position: center; display: flex; align-items: flex-end; padding: 40px; margin-bottom: 40px; border-radius: 20px; position: relative; }
        .hero-content { max-width: 600px; }
        .hero h1 { font-size: 48px; margin-bottom: 20px; text-shadow: 2px 2px 10px rgba(0,0,0,0.8); }
        .btn { background: var(--primary); color: white; padding: 15px 40px; border: none; border-radius: 50px; font-size: 18px; font-weight: bold; cursor: pointer; transition: 0.3s; }
        .btn:hover { background: #ff6b7b; transform: scale(1.05); }
        .section-title { font-size: 24px; margin-bottom: 20px; color: var(--text); }
        .anime-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 25px; }
        .anime-card { background: var(--dark-card); border-radius: 15px; overflow: hidden; transition: 0.3s; cursor: pointer; position: relative; }
        .anime-card:hover { transform: translateY(-10px); box-shadow: 0 10px 30px rgba(255, 71, 87, 0.2); }
        .anime-card img { width: 100%; height: 300px; object-fit: cover; }
        .anime-info { padding: 15px; }
        .anime-title { font-size: 16px; font-weight: bold; margin-bottom: 5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .anime-meta { display: flex; justify-content: space-between; font-size: 12px; color: var(--text-gray); }
        .rating { color: #4cd137; font-weight: bold; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.95); z-index: 1000; justify-content: center; align-items: center; flex-direction: column; }
        .modal-content { width: 90%; max-width: 1200px; background: var(--dark-card); border-radius: 20px; overflow: hidden; position: relative; }
        .video-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; }
        .video-container iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
        .close-btn { position: absolute; top: 20px; right: 30px; font-size: 40px; color: white; cursor: pointer; z-index: 1001; }
        .modal-info { padding: 30px; }
        footer { text-align: center; padding: 40px; color: var(--text-gray); margin-top: 50px; border-top: 1px solid #2a2d35; }
        .loading { text-align: center; padding: 20px; color: var(--text-gray); }
    </style>
</head>
<body>
    <header>
        <a href="#" class="logo">ANISTREAM</a>
        <div class="search-box">
            <span>🔍</span>
            <input type="text" placeholder="Search anime..." id="searchInput">
        </div>
    </header>
    <main>
        <div class="hero">
            <div class="hero-content">
                <h1>Free Anime Streaming</h1>
                <p style="margin-bottom: 20px; font-size: 18px; color: #ccc;">Search and watch anime instantly.</p>
            </div>
        </div>
        <h2 class="section-title">Recent Releases</h2>
        <div id="loading" class="loading">Loading anime catalog...</div>
        <div class="anime-grid" id="animeGrid"></div>
    </main>
    <div class="modal" id="videoModal">
        <div class="close-btn" onclick="closeModal()">&times;</div>
        <div class="modal-content">
            <div class="video-container">
                <iframe id="videoFrame" src="" allowfullscreen></iframe>
            </div>
            <div class="modal-info">
                <h2 id="modalTitle">Loading...</h2>
                <p style="color: var(--text-gray); margin-top: 10px;">If the video does not load, the source link may be blocked by CORS or removed.</p>
            </div>
        </div>
    </div>
    <footer>
        <p>AniStream © 2024. Educational Demo.</p>
    </footer>
    <script>
        const API_BASE = 'https://api.consumet.org/anime/gogoanime';
        const grid = document.getElementById('animeGrid');
        const loading = document.getElementById('loading');
        const modal = document.getElementById('videoModal');
        const videoFrame = document.getElementById('videoFrame');
        const modalTitle = document.getElementById('modalTitle');
        const searchInput = document.getElementById('searchInput');

        async function fetchAnime(query = '') {
            grid.innerHTML = '';
            loading.style.display = 'block';
            try {
                const url = query 
                    ? `${API_BASE}/${query}` 
                    : `${API_BASE}/recent-episodes?page=1`;
                
                const response = await fetch(url);
                const data = await response.json();
                
                loading.style.display = 'none';
                
                if (data.results && data.results.length > 0) {
                    renderGrid(data.results);
                } else {
                    grid.innerHTML = '<p style="grid-column: 1/-1; text-align: center;">No results found or API blocked by CORS.</p>';
                }
            } catch (error) {
                loading.style.display = 'none';
                grid.innerHTML = `<p style="grid-column: 1/-1; text-align: center; color: red;">Error: ${error.message}. <br>Note: Direct browser access to this API is often blocked by CORS. You may need a proxy or backend.</p>`;
            }
        }

        function renderGrid(animeList) {
            animeList.forEach(anime => {
                if (!anime.id || !anime.image) return;
                const card = document.createElement('div');
                card.className = 'anime-card';
                card.innerHTML = `
                    <img src="${anime.image}" alt="${anime.title}">
                    <div class="anime-info">
                        <div class="anime-title">${anime.title}</div>
                        <div class="anime-meta">
                            <span>${anime.releaseDate || 'N/A'}</span>
                            <span style="color: #4cd137">HD</span>
                        </div>
                    </div>
                `;
                card.addEventListener('click', () => loadAnime(anime.id));
                grid.appendChild(card);
            });
        }

        async function loadAnime(id) {
            modalTitle.textContent = "Loading Stream...";
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            
            try {
                const response = await fetch(`${API_BASE}/watch/${id}`);
                const data = await response.json();
                
                if (data.sources && data.sources.length > 0) {
                    const streamUrl = data.sources.find(s => s.quality === 'default') || data.sources[0];
                    videoFrame.src = streamUrl.url;
                    modalTitle.textContent = "Watching: " + id;
                } else {
                    modalTitle.textContent = "No stream available";
                    videoFrame.src = "";
                }
            } catch (error) {
                modalTitle.textContent = "Error loading stream";
                videoFrame.src = "";
            }
        }

        function closeModal() {
            modal.style.display = 'none';
            videoFrame.src = '';
            document.body.style.overflow = 'auto';
        }

        searchInput.addEventListener('input', (e) => {
            const val = e.target.value.trim();
            if (val.length > 2) {
                fetchAnime(val);
            } else if (val.length === 0) {
                fetchAnime();
            }
        });

        window.onclick = function(event) {
            if (event.target == modal) {
                closeModal();
            }
        }

        fetchAnime();
    </script>
</body>
</html>
