# Project Architecture Documentation

This document provides a detailed overview of the technology stack and data flow pipeline for the Rayquaza Web App project.

## 1. Technology Stack

The Rayquaza Web App is a full-stack application composed of a Flutter frontend and a Dart backend, leveraging various libraries and tools for efficient development and robust functionality.

### 1.1. Frontend (Flutter)

*   **Framework:** Flutter (for cross-platform web, desktop, and mobile applications)
    *   **Language:** Dart
*   **State Management:** GetX
    *   A fast, powerful, and lightweight solution for state management, dependency injection, and route management.
*   **HTTP Client:** Dio
    *   A powerful HTTP client for Dart, used for making network requests to the backend.
*   **Local Storage:** GetStorage
    *   A fast, synchronous, and secure key-value store used for persisting user preferences (e.g., theme mode).
*   **Architecture Pattern:** MVVM (Model-View-ViewModel)
    *   **Model:** Defined by `ClientEntity` (data structure) and `ClientDTO` (data transfer objects for API interaction).
    *   **View:** Implemented as Flutter `StatelessWidget`s (e.g., `ClientPage`, `EditClient`). These are responsible for UI rendering and user interaction.
    *   **ViewModel:** Implemented using GetX Controllers (e.g., `ClientController`, `ThemeController`). These expose observable data and methods for the View to interact with, abstracting business logic and data fetching.
*   **UI Structure:** Organized into `lib/ui/pages`, `lib/ui/widgets`, and `lib/ui/components` for modularity and reusability.

### 1.2. Backend (Dart - Vaden Framework)

*   **Framework:** Vaden
    *   A Dart-based backend framework used for building RESTful APIs.
    *   **Language:** Dart
*   **HTTP Client (Internal):** Dio
    *   Used within the Vaden backend to make requests to the JSON Server, acting as a proxy.
*   **Database (Currently Disabled/Proxied):** PostgreSQL (intended, but currently bypassed by JSON Server proxy)
    *   The original intention was to use PostgreSQL for data persistence. However, for development and demonstration purposes, the backend now proxies requests to a JSON Server.
*   **JSON Server:** `json-server` (Node.js based)
    *   A full fake REST API that serves data from a `db.json` file. It provides a quick way to simulate a backend without a real database.
*   **JSON Server Control:** Python Script (`json_server_controller.py`)
    *   A utility script to programmatically start and stop the `json-server` process.

### 1.3. Architectural Principles Applied

*   **MVVM (Model-View-ViewModel):** Applied in the Flutter frontend for clear separation of concerns, improving testability and maintainability.
*   **SOLID Principles:**
    *   **Single Responsibility Principle (SRP):** Classes like `ClientService` (data operations), `HttpClientService` (HTTP requests), `ClientController` (UI logic/state) each have a single, well-defined responsibility.
    *   **Open/Closed Principle (OCP):** Achieved through interfaces and abstract classes (though not explicitly shown in the provided snippets, it's a general principle for extensible code).
    *   **Liskov Substitution Principle (LSP):** Ensured by proper inheritance and interface implementation in Dart.
    *   **Interface Segregation Principle (ISP):** Promoted by creating focused interfaces (e.g., `HttpClientService` defines only HTTP methods).
    *   **Dependency Inversion Principle (DIP):** Demonstrated by injecting dependencies (e.g., `Dio` into `HttpClientService`, `HttpClientService` into `ClientService`, `ClientService` into `ClientController`) rather than hardcoding them. This allows for easier testing and swapping implementations.
*   **Object-Oriented Programming (OOP):**
    *   **Encapsulation:** Data and methods are bundled within classes (e.g., `ClientEntity`, `ClientDTO`, `HttpClientService`). Internal state is protected.
    *   **Inheritance:** Used where appropriate to extend functionality (e.g., `GetxController` in GetX).
    *   **Polymorphism:** Achieved through method overriding and interface implementation.
    *   **Abstraction:** Provided by interfaces and abstract classes, hiding complex implementation details.

## 2. Data Flow Pipeline (Flowchart Description)

The following describes the typical data flow for a client/lead management operation, from the Flutter frontend to the JSON Server and back.

```mermaid
graph TD
    A[Flutter Frontend] -->|User Interaction (e.g., Add Client)| B(UI Layer - ClientPage/EditClient)
    B -->|Calls Method on| C(ViewModel - ClientController)
    C -->|Calls Method on| D(Service Layer - ClientService)
    D -->|Calls Method on| E(HTTP Client - HttpClientService)
    E -->|HTTP Request (e.g., POST /json-proxy/clients)| F(Vaden Backend - JsonProxyController)
    F -->|Internal HTTP Request (e.g., POST http://localhost:3000/clients)| G(JSON Server)
    G -->|Persists/Retrieves Data| H(db.json)
    G -->|JSON Response| F
    F -->|HTTP Response| E
    E -->|Data Transformation| D
    D -->|Data Processing| C
    C -->|Updates Observable State| B
    B -->|UI Updates| A

    subgraph Frontend
        A
        B
        C
        D
        E
    end

    subgraph Backend
        F
        G
        H
    end

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#ccf,stroke:#333,stroke-width:2px
    style C fill:#cfc,stroke:#333,stroke-width:2px
    style D fill:#ffc,stroke:#333,stroke-width:2px
    style E fill:#fcc,stroke:#333,stroke-width:2px
    style F fill:#cff,stroke:#333,stroke-width:2px
    style G fill:#fcf,stroke:#333,stroke-width:2px
    style H fill:#eee,stroke:#333,stroke-width:2px
```

**Explanation of the Flow:**

1.  **User Interaction (Flutter Frontend):** The user interacts with the application's UI (e.g., clicks a button to add a new client on `ClientPage` or fills out a form on `EditClient`).
2.  **UI Layer (View):** The `ClientPage` or `EditClient` (Flutter `StatelessWidget`s) captures the user's input or action.
3.  **ViewModel (ClientController):** The UI layer calls a method on the `ClientController` (a GetX Controller). The `ClientController` contains the presentation logic and orchestrates the data flow.
4.  **Service Layer (ClientService):** The `ClientController` calls a method on the `ClientService`. This service is responsible for the application's business logic related to clients and acts as an abstraction over the data source.
5.  **HTTP Client (HttpClientService):** The `ClientService` uses the `HttpClientService` (which is a wrapper around `Dio`) to make an HTTP request. This request is directed to the Vaden backend's `/json-proxy` endpoint.
6.  **Vaden Backend (JsonProxyController):** The Vaden backend receives the HTTP request. The `JsonProxyController` is specifically designed to handle requests to `/json-proxy`. Instead of interacting with a database, it acts as an intermediary.
7.  **Internal HTTP Request (Vaden to JSON Server):** The `JsonProxyController` then makes an *internal* HTTP request (using its own `Dio` instance) to the `json-server` (typically running on `http://localhost:3000`). This request mirrors the original request from the Flutter app (e.g., `POST /clients`).
8.  **JSON Server:** The `json-server` receives the request and performs the requested operation (e.g., adds a new client to `db.json`, retrieves clients from `db.json`).
9.  **Data Persistence (db.json):** The `db.json` file is where the JSON Server stores its data.
10. **JSON Response (JSON Server to Vaden):** The `json-server` sends a JSON response back to the Vaden backend.
11. **HTTP Response (Vaden to Flutter):** The `JsonProxyController` in the Vaden backend receives the response from the JSON Server and forwards it back as an HTTP response to the Flutter frontend's `HttpClientService`.
12. **Data Transformation/Processing (Service Layer):** The `HttpClientService` receives the response, and the `ClientService` processes and transforms the raw data into `ClientEntity` objects.
13. **Updates Observable State (ViewModel):** The `ClientController` receives the processed data and updates its observable state (e.g., `clients.obs`, `isLoading.obs`).
14. **UI Updates (UI Layer):** The UI layer (e.g., `ClientPage`) observes the changes in the `ClientController`'s observable state and automatically rebuilds to reflect the new data, providing real-time updates to the user.

This pipeline ensures a clear separation of concerns and allows for flexible development and testing, as the backend's data source can be easily swapped (e.g., from JSON Server to a real PostgreSQL database) without affecting the frontend logic.
