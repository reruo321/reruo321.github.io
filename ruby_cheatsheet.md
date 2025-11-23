# === HOW TO START MY BLOG LOCALLY (reruo321.github.io) ===

# 1. Open the folder
cd C:\Users\reruo\reruo321.github.io
   (or wherever your blog is)

# 2. Make sure Ruby + Bundler are still installed
ruby -v
   → should show something like ruby 3.4.x
bundler -v
   → should show 2.x.x

   If any of these commands say “not recognized” → reinstall Ruby+Devkit from
   https://rubyinstaller.org/downloads/ (choose the latest “Ruby+Devkit” version)

# 3. Install / update all gems (only needed the very first time or after months)
bundle install
   (this reads your Gemfile and installs github-pages, jekyll, wdm, etc.)

# 4. Start the local server (this is the only command you really need every day)
bundle exec jekyll serve --livereload

# 5. Open browser
http://127.0.0.1:4000
   → you will see your blog with instant auto-refresh when you edit files

# Optional but super useful
# – If you see the “wdm” warning again → it’s harmless, just keep going
# – If you want to use a different port because 4000 is busy:
bundle exec jekyll serve --livereload --port 4001