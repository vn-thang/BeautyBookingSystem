import axios from 'axios';
const CLOUD_NAME = 'drkpkiu7e'; 
const UPLOAD_PRESET = 'admin_web_upload'; 

export const uploadToCloudinary = async (file, folderName = 'general') => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('upload_preset', UPLOAD_PRESET);
  formData.append('folder', folderName); 

  try {
    const res = await axios.post(
      `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload`,
      formData
    );
    return res.data.secure_url; 
  } catch (error) {
    console.error("Lỗi upload Cloudinary:", error);
    throw new Error('Không thể tải ảnh lên máy chủ Cloudinary!');
  }
};