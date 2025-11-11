package com.pokemon.cards.data.database

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.database.Cursor
import com.pokemon.cards.data.model.PokemonCard

class PokemonDatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "pokemon_cards.db"
        private const val DATABASE_VERSION = 1
        
        // Table name
        const val TABLE_CARDS = "cards"
        
        // Column names
        const val COLUMN_ID = "id"
        const val COLUMN_NAME = "name"
        const val COLUMN_IMAGE_URL = "image_url"
        const val COLUMN_IMAGE_URL_HIRES = "image_url_hires"
        const val COLUMN_SUPERTYPE = "supertype"
        const val COLUMN_SUBTYPE = "subtype"
        const val COLUMN_HP = "hp"
        const val COLUMN_ARTIST = "artist"
        const val COLUMN_RARITY = "rarity"
        const val COLUMN_SERIES = "series"
        const val COLUMN_SET = "card_set"
        const val COLUMN_SET_CODE = "set_code"
        const val COLUMN_NUMBER = "number"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = """
            CREATE TABLE $TABLE_CARDS (
                $COLUMN_ID TEXT PRIMARY KEY,
                $COLUMN_NAME TEXT NOT NULL,
                $COLUMN_IMAGE_URL TEXT NOT NULL,
                $COLUMN_IMAGE_URL_HIRES TEXT,
                $COLUMN_SUPERTYPE TEXT,
                $COLUMN_SUBTYPE TEXT,
                $COLUMN_HP TEXT,
                $COLUMN_ARTIST TEXT,
                $COLUMN_RARITY TEXT,
                $COLUMN_SERIES TEXT,
                $COLUMN_SET TEXT,
                $COLUMN_SET_CODE TEXT,
                $COLUMN_NUMBER TEXT
            )
        """.trimIndent()
        db.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_CARDS")
        onCreate(db)
    }

    fun insertCard(card: PokemonCard): Long {
        val db = writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_ID, card.id)
            put(COLUMN_NAME, card.name)
            put(COLUMN_IMAGE_URL, card.imageUrl)
            put(COLUMN_IMAGE_URL_HIRES, card.imageUrlHiRes)
            put(COLUMN_SUPERTYPE, card.supertype)
            put(COLUMN_SUBTYPE, card.subtype)
            put(COLUMN_HP, card.hp)
            put(COLUMN_ARTIST, card.artist)
            put(COLUMN_RARITY, card.rarity)
            put(COLUMN_SERIES, card.series)
            put(COLUMN_SET, card.set)
            put(COLUMN_SET_CODE, card.setCode)
            put(COLUMN_NUMBER, card.number)
        }
        return db.insertWithOnConflict(TABLE_CARDS, null, values, SQLiteDatabase.CONFLICT_REPLACE)
    }

    fun insertCards(cards: List<PokemonCard>) {
        val db = writableDatabase
        db.beginTransaction()
        try {
            cards.forEach { card ->
                insertCard(card)
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
    }

    fun getAllCards(): List<PokemonCard> {
        val cards = mutableListOf<PokemonCard>()
        val db = readableDatabase
        val cursor: Cursor = db.query(TABLE_CARDS, null, null, null, null, null, "$COLUMN_NAME ASC")
        
        if (cursor.moveToFirst()) {
            do {
                cards.add(cursorToCard(cursor))
            } while (cursor.moveToNext())
        }
        cursor.close()
        return cards
    }

    fun getCardById(id: String): PokemonCard? {
        val db = readableDatabase
        val cursor = db.query(
            TABLE_CARDS,
            null,
            "$COLUMN_ID = ?",
            arrayOf(id),
            null,
            null,
            null
        )
        
        var card: PokemonCard? = null
        if (cursor.moveToFirst()) {
            card = cursorToCard(cursor)
        }
        cursor.close()
        return card
    }

    fun deleteAllCards() {
        val db = writableDatabase
        db.delete(TABLE_CARDS, null, null)
    }

    private fun cursorToCard(cursor: Cursor): PokemonCard {
        return PokemonCard(
            id = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_ID)),
            name = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NAME)),
            imageUrl = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_IMAGE_URL)),
            imageUrlHiRes = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_IMAGE_URL_HIRES)),
            supertype = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_SUPERTYPE)),
            subtype = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_SUBTYPE)),
            hp = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_HP)),
            artist = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_ARTIST)),
            rarity = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_RARITY)),
            series = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_SERIES)),
            set = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_SET)),
            setCode = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_SET_CODE)),
            number = cursor.getString(cursor.getColumnIndexOrThrow(COLUMN_NUMBER))
        )
    }
}
