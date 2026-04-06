import React, { useEffect, useState } from 'react';
import { Drawer, Form, Input, Switch, Button, message, Spin, Select, Divider, Space, Typography } from 'antd';
import { FileTextOutlined, SaveOutlined, SendOutlined } from '@ant-design/icons';
import ReactQuill from 'react-quill-new';
import 'react-quill-new/dist/quill.snow.css';
import { systemContentApi } from '../api/systemContentApi';

const { Text } = Typography;

const ContentEditorDrawer = ({ open, onClose, contentId, onSuccess }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const isCreating = !contentId;

  useEffect(() => {
    if (open) {
      if (contentId) {
        const fetchDetail = async () => {
          setLoading(true);
          try {
            const res = await systemContentApi.getByIdAdmin(contentId);
            const data = res.data || res;
            form.setFieldsValue({
              type: data.type,
              title: data.title,
              isActive: data.isActive,
              content: data.content,
            });
          } catch (error) {
            message.error('Lỗi tải dữ liệu!');
            onClose();
          } finally {
            setLoading(false);
          }
        };
        fetchDetail();
      } else {
        form.resetFields();
        form.setFieldsValue({ isActive: true });
      }
    }
  }, [open, contentId, form]);

  const onSave = async () => {
    try {
      const values = await form.validateFields();
      setSaving(true);
      if (isCreating) {
        await systemContentApi.createContent(values);
        message.success('Tạo mới thành công!');
      } else {
        await systemContentApi.updateContent(contentId, values);
        message.success('Đã lưu thay đổi!');
      }
      onSuccess();
      onClose();
    } catch (error) {
      if (!error.errorFields) message.error('Thao tác thất bại!');
    } finally {
      setSaving(false);
    }
  };

  return (
    <Drawer
      title={
        <Space>
          <div style={{ backgroundColor: '#F5F3FF', padding: '6px 8px', borderRadius: '8px', color: '#4318FF' }}>
            <FileTextOutlined />
          </div>
          <span style={{ fontSize: '18px', fontWeight: 600, color: '#1E293B' }}>
            {isCreating ? "Soạn nội dung mới" : "Chỉnh sửa nội dung"}
          </span>
        </Space>
      }
      width={900}
      onClose={onClose}
      open={open}
      destroyOnClose
      extra={
        <Space>
          <Button onClick={onClose}>Hủy bỏ</Button>
          <Button 
            type="primary" 
            icon={isCreating ? <SendOutlined /> : <SaveOutlined />} 
            onClick={onSave} 
            loading={saving}
            style={{ backgroundColor: '#4318FF' }}
          >
            {isCreating ? "Đăng bài" : "Lưu thay đổi"}
          </Button>
        </Space>
      }
    >
      <Spin spinning={loading}>
        <Form form={form} layout="vertical" size="large">
          
          <div style={{ display: 'flex', gap: '24px' }}>
            <Form.Item 
              name="type" 
              label={<Text strong style={{ color: '#1E293B' }}>Loại bài viết</Text>} 
              style={{ flex: 1 }} 
              rules={[{ required: true, message: 'Vui lòng chọn loại bài viết!' }]}
            >
              <Select disabled={!isCreating} placeholder="Chọn phân loại">
                <Select.Option value={1}>Điều khoản sử dụng</Select.Option>
                <Select.Option value={2}>Chính sách bảo mật</Select.Option>
                <Select.Option value={3}>Giới thiệu</Select.Option>
              </Select>
            </Form.Item>
            
            <Form.Item 
              name="isActive" 
              label={<Text strong style={{ color: '#1E293B' }}>Trạng thái</Text>} 
              valuePropName="checked"
            >
              <Switch checkedChildren="Bật hiển thị" unCheckedChildren="Tắt" />
            </Form.Item>
          </div>

          <Form.Item 
            name="title" 
            label={<Text strong style={{ color: '#1E293B' }}>Tiêu đề bài viết</Text>} 
            rules={[{ required: true, message: 'Vui lòng nhập tiêu đề!' }]}
          >
            <Input placeholder="Nhập tiêu đề hiển thị cho khách hàng..." />
          </Form.Item>

        <Divider orientation="left" style={{ margin: '24px 0', color: '#64748b' }}>Nội dung chi tiết</Divider>

          <Form.Item 
            name="content" 
            rules={[{ required: true, message: 'Nội dung không được để trống!' }]}
          >
            <ReactQuill 
              theme="snow" 
              placeholder="Viết nội dung chi tiết tại đây..."
              style={{ height: '400px', marginBottom: '40px' }} 
            />
          </Form.Item>
          
        </Form>
      </Spin>
    </Drawer>
  );
};

export default ContentEditorDrawer;