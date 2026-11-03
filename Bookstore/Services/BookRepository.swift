import Foundation

protocol BookRepository {
    func allBooks() -> [Book]
    func book(withID id: String) -> Book?
}

/// In-memory catalog used by the front-end. Swap for a networked implementation later.
struct MockBookRepository: BookRepository {

    private let books: [Book]

    init(books: [Book] = MockBookRepository.sampleBooks) {
        self.books = books
    }

    func allBooks() -> [Book] { books }

    func book(withID id: String) -> Book? {
        books.first { $0.id == id }
    }

    private static func price(_ value: String) -> Decimal {
        Decimal(string: value, locale: Locale(identifier: "en_US")) ?? 0
    }

    static let sampleBooks: [Book] = [
        Book(id: "b01", title: "The Midnight Library", author: "Matt Haig", genre: .fiction,
             synopsis: "Between life and death there is a library, and within that library, the shelves go on forever. Every book provides a chance to try another life you could have lived.",
             price: price("14.99"), rating: 4.4, pageCount: 304, publishedYear: 2020, isBestseller: true,
             coverColors: [0x1B2A49, 0x6A4C93]),
        Book(id: "b02", title: "Project Hail Mary", author: "Andy Weir", genre: .scienceFiction,
             synopsis: "A lone astronaut wakes up on a spacecraft with no memory of who he is, and must save humanity and Earth with the help of an unlikely ally.",
             price: price("18.99"), rating: 4.8, pageCount: 496, publishedYear: 2021, isBestseller: true,
             coverColors: [0x0B132B, 0x3A86FF]),
        Book(id: "b03", title: "The Silent Patient", author: "Alex Michaelides", genre: .mystery,
             synopsis: "Alicia Berenson shot her husband five times and then never spoke another word. A criminal psychotherapist is determined to unravel the mystery.",
             price: price("13.49"), rating: 4.2, pageCount: 336, publishedYear: 2019, isBestseller: false,
             coverColors: [0x2B2D42, 0xEF233C]),
        Book(id: "b04", title: "Dune", author: "Frank Herbert", genre: .scienceFiction,
             synopsis: "Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family tasked with ruling an inhospitable world.",
             price: price("17.99"), rating: 4.7, pageCount: 688, publishedYear: 1965, isBestseller: true,
             coverColors: [0x7F4F24, 0xDDA15E]),
        Book(id: "b05", title: "The Name of the Wind", author: "Patrick Rothfuss", genre: .fantasy,
             synopsis: "The tale of Kvothe, a legendary figure, as he recounts his own story: from a childhood in a troupe of traveling performers to the University.",
             price: price("16.99"), rating: 4.6, pageCount: 662, publishedYear: 2007, isBestseller: false,
             coverColors: [0x264653, 0x2A9D8F]),
        Book(id: "b06", title: "Educated", author: "Tara Westover", genre: .biography,
             synopsis: "A memoir about a young woman who, kept out of school, leaves her survivalist family and goes on to earn a PhD from Cambridge University.",
             price: price("15.99"), rating: 4.7, pageCount: 352, publishedYear: 2018, isBestseller: true,
             coverColors: [0x4A4E69, 0xC9ADA7]),
        Book(id: "b07", title: "Atomic Habits", author: "James Clear", genre: .nonFiction,
             synopsis: "A proven framework for improving every day. Tiny changes, remarkable results: build good habits, break bad ones, and master the tiny behaviors that lead to success.",
             price: price("16.49"), rating: 4.8, pageCount: 320, publishedYear: 2018, isBestseller: true,
             coverColors: [0xE76F51, 0xF4A261]),
        Book(id: "b08", title: "Gone Girl", author: "Gillian Flynn", genre: .mystery,
             synopsis: "On a warm summer morning on their fifth wedding anniversary, Nick Dunne's wife Amy disappears. Is Nick a killer, or is something far stranger going on?",
             price: price("12.99"), rating: 4.1, pageCount: 432, publishedYear: 2012, isBestseller: false,
             coverColors: [0x370617, 0xD00000]),
        Book(id: "b09", title: "The Hobbit", author: "J.R.R. Tolkien", genre: .fantasy,
             synopsis: "Bilbo Baggins is a hobbit who enjoys a comfortable, unambitious life until the wizard Gandalf and thirteen dwarves whisk him away on an adventure.",
             price: price("11.99"), rating: 4.8, pageCount: 310, publishedYear: 1937, isBestseller: true,
             coverColors: [0x386641, 0xA7C957]),
        Book(id: "b10", title: "Sapiens", author: "Yuval Noah Harari", genre: .nonFiction,
             synopsis: "A brief history of humankind, exploring how Homo sapiens came to dominate the planet through cognitive, agricultural and scientific revolutions.",
             price: price("19.99"), rating: 4.6, pageCount: 464, publishedYear: 2011, isBestseller: false,
             coverColors: [0x5F0F40, 0xFB8B24]),
        Book(id: "b11", title: "Circe", author: "Madeline Miller", genre: .fantasy,
             synopsis: "In the house of Helios, god of the sun, a daughter is born who is not like her siblings. Circe discovers the power of witchcraft and is banished to an island.",
             price: price("15.49"), rating: 4.5, pageCount: 400, publishedYear: 2018, isBestseller: false,
             coverColors: [0x003049, 0xFCBF49]),
        Book(id: "b12", title: "Becoming", author: "Michelle Obama", genre: .biography,
             synopsis: "An intimate, powerful and inspiring memoir by the former First Lady of the United States, tracing her journey from Chicago's South Side to the White House.",
             price: price("22.99"), rating: 4.7, pageCount: 448, publishedYear: 2018, isBestseller: true,
             coverColors: [0x3D405B, 0xE07A5F]),
        Book(id: "b13", title: "Neuromancer", author: "William Gibson", genre: .scienceFiction,
             synopsis: "Case was the best interface cowboy in the Sprawl until he crossed the wrong people. Hired for one last job, he enters a dazzling cyberspace conspiracy.",
             price: price("10.99"), rating: 4.0, pageCount: 271, publishedYear: 1984, isBestseller: false,
             coverColors: [0x10002B, 0x00F5D4]),
        Book(id: "b14", title: "Where the Crawdads Sing", author: "Delia Owens", genre: .fiction,
             synopsis: "For years, rumors of the Marsh Girl have haunted Barkley Cove. When a local man is found dead, the town immediately suspects Kya Clark.",
             price: price("16.99"), rating: 4.5, pageCount: 384, publishedYear: 2018, isBestseller: true,
             coverColors: [0x1B4332, 0x74C69D]),
        Book(id: "b15", title: "The Da Vinci Code", author: "Dan Brown", genre: .mystery,
             synopsis: "While in Paris, Harvard symbologist Robert Langdon is awakened by a phone call in the dead of night. The curator of the Louvre has been murdered.",
             price: price("9.99"), rating: 3.9, pageCount: 489, publishedYear: 2003, isBestseller: false,
             coverColors: [0x1D3557, 0xE63946]),
        Book(id: "b16", title: "A Brief History of Time", author: "Stephen Hawking", genre: .nonFiction,
             synopsis: "From the Big Bang to black holes, Hawking guides readers through the greatest mysteries of the cosmos in clear, accessible language.",
             price: price("27.50"), rating: 4.4, pageCount: 256, publishedYear: 1988, isBestseller: false,
             coverColors: [0x03045E, 0x90E0EF])
    ]
}
