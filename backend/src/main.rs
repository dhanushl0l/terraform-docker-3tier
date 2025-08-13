use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use sqlx::{PgPool, FromRow};
use std::env;

#[derive(Serialize, FromRow)]
struct Example {
    id: i32,
    name: String,
    role: String,
    email: String,
}

#[derive(Deserialize)]
struct NewExample {
    name: String,
    role: String,
    email: String,
}

async fn get(pool: web::Data<PgPool>) -> impl Responder {
    let rows: Result<Vec<Example>, _> = sqlx::query_as::<_, Example>(
        "SELECT id, name, role, email FROM example"
    )
    .fetch_all(pool.get_ref())
    .await;

    match rows {
        Ok(data) => HttpResponse::Ok().json(data),
        Err(e) => HttpResponse::InternalServerError().body(format!("Error: {}", e)),
    }
}

async fn create(pool: web::Data<PgPool>, item: web::Json<NewExample>) -> impl Responder {
    let res = sqlx::query(
        "INSERT INTO example (name, role, email) VALUES ($1, $2, $3)"
    )
    .bind(&item.name)
    .bind(&item.role)
    .bind(&item.email)
    .execute(pool.get_ref())
    .await;

    match res {
        Ok(_) => HttpResponse::Ok().body("Inserted successfully"),
        Err(e) => HttpResponse::InternalServerError().body(format!("Error: {}", e)),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv::dotenv().ok();
    let db_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let pool = PgPool::connect(&db_url)
        .await
        .expect("Failed to connect to Postgres");

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .route("/get", web::get().to(get))
            .route("/create", web::post().to(create))
    })
    .bind(("0.0.0.0", 8081))?
    .run()
    .await
}
