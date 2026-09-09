import streamlit as st
import pandas as pd
from database import query_df, execute, call_procedure

st.set_page_config(page_title="CineVerse", page_icon="🎬", layout="wide")

st.title("🎬 CineVerse - Movie Discovery Platform")
st.caption("MySQL + Streamlit real-life SQL project")

def load_catalog():
    return query_df("SELECT * FROM movie_catalog ORDER BY popularity DESC")

menu = st.sidebar.radio(
    "Navigate",
    ["Home","Discover Movies","Genre Explorer","Actor Explorer",
     "Rate a Movie","Reviews","Favorites","Analytics","SQL Query Lab"]
)

if menu == "Home":
    c1,c2,c3,c4 = st.columns(4)
    c1.metric("Movies", int(query_df("SELECT COUNT(*) total FROM movies").iloc[0,0]))
    c2.metric("Users", int(query_df("SELECT COUNT(*) total FROM users").iloc[0,0]))
    c3.metric("Ratings", int(query_df("SELECT COUNT(*) total FROM ratings").iloc[0,0]))
    c4.metric("Platforms", int(query_df("SELECT COUNT(*) total FROM streaming_platforms").iloc[0,0]))
    st.subheader("🔥 Trending Movies")
    st.dataframe(query_df("""
        SELECT title,genres,imdb_rating,average_user_rating,popularity
        FROM movie_catalog ORDER BY popularity DESC LIMIT 10
    """), use_container_width=True)

elif menu == "Discover Movies":
    df = load_catalog()
    genres = ["All"] + sorted(query_df("SELECT genre_name FROM genres")["genre_name"].tolist())
    languages = ["All"] + sorted(query_df("SELECT DISTINCT language FROM movies")["language"].tolist())
    col1,col2,col3 = st.columns(3)
    keyword = col1.text_input("Search title")
    genre = col2.selectbox("Genre",genres)
    language = col3.selectbox("Language",languages)
    year_range = st.slider("Release year",2009,2024,(2009,2024))
    result = df.copy()
    if keyword:
        result=result[result["title"].str.contains(keyword,case=False)]
    if genre!="All":
        result=result[result["genres"].str.contains(genre,case=False)]
    if language!="All":
        result=result[result["language"]==language]
    result=result[(result["release_year"]>=year_range[0]) & (result["release_year"]<=year_range[1])]
    st.dataframe(result,use_container_width=True)

elif menu == "Genre Explorer":
    genre = st.selectbox("Choose genre",query_df("SELECT genre_name FROM genres")["genre_name"])
    df = call_procedure("GetMoviesByGenre",(genre,))
    st.dataframe(df,use_container_width=True)
    st.bar_chart(df.set_index("title")["imdb_rating"])

elif menu == "Actor Explorer":
    actors = query_df("SELECT actor_id,actor_name FROM actors ORDER BY actor_name")
    actor_name = st.selectbox("Actor",actors["actor_name"])
    actor_id = int(actors[actors.actor_name==actor_name].actor_id.iloc[0])
    df = query_df("""
        SELECT m.title,d.director_name,m.release_year,m.imdb_rating,mc.character_name
        FROM movie_cast mc
        JOIN movies m ON mc.movie_id=m.movie_id
        JOIN directors d ON m.director_id=d.director_id
        WHERE mc.actor_id=%s
        ORDER BY m.release_year DESC
    """,(actor_id,))
    st.dataframe(df,use_container_width=True)

elif menu == "Rate a Movie":
    users=query_df("SELECT user_id,user_name FROM users")
    movies=query_df("SELECT movie_id,title FROM movies ORDER BY title")
    user=st.selectbox("User",users.user_name)
    movie=st.selectbox("Movie",movies.title)
    rating=st.slider("Rating",1.0,5.0,4.0,0.5)
    if st.button("Submit Rating"):
        uid=int(users[users.user_name==user].user_id.iloc[0])
        mid=int(movies[movies.title==movie].movie_id.iloc[0])
        try:
            execute("""
                INSERT INTO ratings(user_id,movie_id,rating)
                VALUES(%s,%s,%s)
                ON DUPLICATE KEY UPDATE rating=VALUES(rating),rated_on=CURRENT_TIMESTAMP
            """,(uid,mid,rating))
            st.success("Rating saved. Trigger automatically refreshed movie average rating.")
        except Exception as e:
            st.error(str(e))

elif menu == "Reviews":
    users=query_df("SELECT user_id,user_name FROM users")
    movies=query_df("SELECT movie_id,title FROM movies ORDER BY title")
    with st.form("review_form"):
        user=st.selectbox("User",users.user_name)
        movie=st.selectbox("Movie",movies.title)
        text=st.text_area("Write review")
        sentiment=st.selectbox("Sentiment",["Positive","Neutral","Negative"])
        submitted=st.form_submit_button("Publish Review")
        if submitted:
            uid=int(users[users.user_name==user].user_id.iloc[0])
            mid=int(movies[movies.title==movie].movie_id.iloc[0])
            execute("INSERT INTO reviews(user_id,movie_id,review_text,sentiment) VALUES(%s,%s,%s,%s)",
                    (uid,mid,text,sentiment))
            st.success("Review published.")
    st.subheader("Recent Reviews")
    st.dataframe(query_df("""
        SELECT u.user_name,m.title,r.review_text,r.sentiment,r.reviewed_on
        FROM reviews r JOIN users u ON r.user_id=u.user_id
        JOIN movies m ON r.movie_id=m.movie_id
        ORDER BY r.reviewed_on DESC
    """),use_container_width=True)

elif menu == "Favorites":
    users=query_df("SELECT user_id,user_name FROM users")
    user=st.selectbox("Choose user",users.user_name)
    uid=int(users[users.user_name==user].user_id.iloc[0])
    movies=query_df("SELECT movie_id,title FROM movies ORDER BY title")
    fav_movie=st.selectbox("Add favorite",movies.title)
    if st.button("Add to Favorites"):
        mid=int(movies[movies.title==fav_movie].movie_id.iloc[0])
        try:
            execute("INSERT INTO favorites(user_id,movie_id) VALUES(%s,%s)",(uid,mid))
            st.success("Added to favorites.")
        except Exception:
            st.warning("Already in favorites.")
    st.dataframe(query_df("""
        SELECT m.title,m.release_year,m.imdb_rating,f.added_on
        FROM favorites f JOIN movies m ON f.movie_id=m.movie_id
        WHERE f.user_id=%s ORDER BY f.added_on DESC
    """,(uid,)),use_container_width=True)

elif menu == "Analytics":
    st.subheader("Language Distribution")
    lang=query_df("SELECT language,COUNT(*) total FROM movies GROUP BY language")
    st.bar_chart(lang.set_index("language"))
    st.subheader("Top Smart Score")
    smart=query_df("""
        SELECT title,MovieScore(imdb_rating,average_user_rating,popularity) smart_score
        FROM movies ORDER BY smart_score DESC
    """)
    st.dataframe(smart,use_container_width=True)
    st.subheader("IMDb Rank using Window Function")
    rank=query_df("""
        SELECT title,imdb_rating,RANK() OVER(ORDER BY imdb_rating DESC) imdb_rank
        FROM movies
    """)
    st.dataframe(rank,use_container_width=True)

elif menu == "SQL Query Lab":
    examples = {
        "Top Rated": "SELECT title, imdb_rating FROM movies ORDER BY imdb_rating DESC",
        "Above Average": "SELECT title, imdb_rating FROM movies WHERE imdb_rating > (SELECT AVG(imdb_rating) FROM movies)",
        "Genre Statistics": "WITH gs AS (SELECT g.genre_name, AVG(m.imdb_rating) avg_rating FROM genres g JOIN movie_genres mg ON g.genre_id=mg.genre_id JOIN movies m ON mg.movie_id=m.movie_id GROUP BY g.genre_name) SELECT * FROM gs ORDER BY avg_rating DESC",
        "Language Rank": "SELECT language,title,imdb_rating,RANK() OVER(PARTITION BY language ORDER BY imdb_rating DESC) language_rank FROM movies"
    }
    choice=st.selectbox("Choose example",list(examples.keys()))
    sql=st.text_area("SQL",examples[choice],height=180)
    if st.button("Run Query"):
        try:
            if sql.strip().lower().startswith("select") or sql.strip().lower().startswith("with"):
                st.dataframe(query_df(sql),use_container_width=True)
            else:
                st.warning("Only SELECT / WITH queries are enabled in Query Lab.")
        except Exception as e:
            st.error(str(e))
