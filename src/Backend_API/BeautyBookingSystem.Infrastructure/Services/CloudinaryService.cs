using BeautyBookingSystem.Application.Interfaces;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.Extensions.Configuration;

public class CloudinaryService : ICloudinaryService
{
    private readonly Cloudinary _cloudinary;

    public CloudinaryService(IConfiguration config)
    {
        var account = new Account(
            config["Cloudinary:CloudName"],
            config["Cloudinary:ApiKey"],
            config["Cloudinary:ApiSecret"]
        );

        _cloudinary = new Cloudinary(account);
    }

    public async Task<string> UploadImageAsync(Stream fileStream, string fileName)
    {
        var uploadParams = new ImageUploadParams
        {
            File = new FileDescription(fileName, fileStream),
            Folder = "avatars"
        };

        var result = await _cloudinary.UploadAsync(uploadParams);

        if (result.StatusCode == System.Net.HttpStatusCode.OK)
        {
            return result.SecureUrl.ToString();
        }

        throw new Exception("Upload image failed");
    }
}