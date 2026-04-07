import React, { useState, useEffect } from 'react';
import { Modal, Form, Input, InputNumber, Switch, Space, Upload, message } from 'antd';
import { LoadingOutlined, PlusOutlined } from '@ant-design/icons';
import { uploadToCloudinary } from '../../../utils/cloudinaryApi';

const CategoryFormModal = ({ visible, editingCategory, onCancel, onSave, confirmLoading }) => {
  const [form] = Form.useForm();
  const [imageUrl, setImageUrl] = useState('');
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    if (visible) {
      if (editingCategory) {
        form.setFieldsValue(editingCategory);
        setImageUrl(editingCategory.iconUrl || '');
      } else {
        form.resetFields();
        form.setFieldsValue({ sortOrder: 0, isActive: true });
        setImageUrl('');
      }
    }
  }, [visible, editingCategory, form]);

  const customUploadRequest = async (options) => {
    const { file, onSuccess, onError } = options;
    try {
      setUploading(true);
      const secureUrl = await uploadToCloudinary(file, 'Categories');
      setImageUrl(secureUrl); 
      form.setFieldsValue({ iconUrl: secureUrl }); 
      onSuccess("ok");
      message.success('Tải ảnh lên thành công!');
    } catch (err) {
      onError(err);
      message.error(err.message || 'Lỗi khi tải ảnh!');
    } finally {
      setUploading(false);
    }
  };

  return (
    <Modal
      title={editingCategory ? "✏️ Chỉnh sửa danh mục" : "✨ Thêm danh mục mới"}
      open={visible}
      onCancel={onCancel}
      onOk={() => form.submit()}
      confirmLoading={confirmLoading || uploading} 
      okText="Lưu danh mục"
      cancelText="Hủy"
      width={480} 
      centered 
    >
      <Form form={form} layout="vertical" onFinish={onSave} style={{ marginTop: '20px' }}>
        <Form.Item 
          name="name" 
          label={<span style={{ fontWeight: 500 }}>Tên danh mục</span>} 
          rules={[{ required: true, message: 'Vui lòng nhập tên danh mục!' }]}
        >
          <Input size="large" placeholder="Ví dụ: Cắt tóc, Spa, Nail..." />
        </Form.Item>

        <Form.Item label={<span style={{ fontWeight: 500 }}>Icon / Hình ảnh đại diện</span>}>
          <Upload
            name="avatar"
            listType="picture-card"
            showUploadList={false}
            customRequest={customUploadRequest}
            beforeUpload={(file) => {
              const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/webp';
              if (!isJpgOrPng) message.error('Chỉ hỗ trợ JPG/PNG/WEBP!');
              const isLt2M = file.size / 1024 / 1024 < 2;
              if (!isLt2M) message.error('Ảnh phải nhỏ hơn 2MB!');
              return isJpgOrPng && isLt2M;
            }}
          >
            {imageUrl ? (
              <img src={imageUrl} alt="icon" style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: '8px' }} />
            ) : (
              <div style={{ color: '#64748b' }}>
                {uploading ? <LoadingOutlined /> : <PlusOutlined />}
                <div style={{ marginTop: 8 }}>Tải ảnh</div>
              </div>
            )}
          </Upload>
        </Form.Item>

        <Form.Item name="iconUrl" hidden><Input /></Form.Item>

        <Space size="large">
          <Form.Item 
            name="sortOrder" 
            label={<span style={{ fontWeight: 500 }}>Thứ tự ưu tiên</span>} 
            rules={[{ required: true }]}
            tooltip="Số càng nhỏ càng xếp lên đầu"
          >
            <InputNumber size="large" min={0} style={{ width: '140px' }} />
          </Form.Item>

          {editingCategory && (
            <Form.Item name="isActive" label={<span style={{ fontWeight: 500 }}>Trạng thái</span>} valuePropName="checked">
              <Switch checkedChildren="Hiển thị" unCheckedChildren="Ẩn" />
            </Form.Item>
          )}
        </Space>
      </Form>
    </Modal>
  );
};

export default CategoryFormModal;