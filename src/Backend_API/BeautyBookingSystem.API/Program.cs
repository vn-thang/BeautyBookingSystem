using AutoMapper;
using BeautyBookingSystem.API.Extensions;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Services;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();

builder.Services.AddApplicationServices(builder.Configuration);

builder.WebHost.UseUrls("http://0.0.0.0:5294");

var app = builder.Build();

app.UseMiddleware<BeautyBookingSystem.API.Middleware.ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();