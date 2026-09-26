# =========================
# 1. Build
# =========================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

# Copy project files
COPY ["BeautyBookingSystem.API/BeautyBookingSystem.API.csproj", "BeautyBookingSystem.API/"]
COPY ["BeautyBookingSystem.Application/BeautyBookingSystem.Application.csproj", "BeautyBookingSystem.Application/"]
COPY ["BeautyBookingSystem.Domain/BeautyBookingSystem.Domain.csproj", "BeautyBookingSystem.Domain/"]
COPY ["BeautyBookingSystem.Infrastructure/BeautyBookingSystem.Infrastructure.csproj", "BeautyBookingSystem.Infrastructure/"]

# Restore
RUN dotnet restore "BeautyBookingSystem.API/BeautyBookingSystem.API.csproj"

# Copy source code
COPY . .

# Publish API
WORKDIR "/src/BeautyBookingSystem.API"

RUN dotnet publish "BeautyBookingSystem.API.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false


# =========================
# 2. Runtime
# =========================
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final

WORKDIR /app

COPY --from=build /app/publish .

# Nếu chạy local mà không có PORT thì dùng 5294.
ENV ASPNETCORE_URLS=http://0.0.0.0:5294

ENTRYPOINT ["dotnet", "BeautyBookingSystem.API.dll"]