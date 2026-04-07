import React, { useState, useEffect } from 'react';
import { Modal, Form, InputNumber, Typography, message, Divider, Space, Input, Select } from 'antd';
import { SettingOutlined, InfoCircleOutlined } from '@ant-design/icons';
import { systemConfigApi } from '../api/systemConfigApi';

const { Text, Title, Paragraph } = Typography;

const SystemConfigModal = ({ isOpen, onClose, onSuccess, editingConfig }) => {
    const [form] = Form.useForm();
    const [submitting, setSubmitting] = useState(false);

    useEffect(() => {
        if (isOpen && editingConfig) {
            form.setFieldsValue({ value: editingConfig.value });
        }
    }, [isOpen, editingConfig, form]);

    const handleSubmit = async () => {
        try {
            const values = await form.validateFields();
            setSubmitting(true);
            
            const response = await systemConfigApi.updateConfig(editingConfig.key, values.value);
            
            if (response.success) {
                message.success('Cập nhật cấu hình thành công!');
                onSuccess();
                onClose();
            }
        } catch (error) {
            if (error.errorFields) return;
            message.error(error.response?.data?.message || 'Cập nhật thất bại!');
        } finally {
            setSubmitting(false);
        }
    };

    const renderInputByType = () => {
        const type = editingConfig?.type?.toLowerCase() || 'string';
        
        switch (type) {
            case 'boolean':
                return (
                    <Select size="large" style={{ width: '100%' }}>
                        <Select.Option value="true">Bật (True)</Select.Option>
                        <Select.Option value="false">Tắt (False)</Select.Option>
                    </Select>
                );
            case 'number':
                return (
                    <InputNumber
                        size="large"
                        style={{ width: '100%', borderRadius: '8px' }}
                        placeholder="Nhập giá trị số..."
                        min={0}
                    />
                );
            case 'string':
            default:
                return (
                    <Input size="large" placeholder="Nhập giá trị văn bản..." style={{ borderRadius: '8px' }} />
                );
        }
    };

    return (
        <Modal
            open={isOpen}
            onOk={handleSubmit}
            onCancel={onClose}
            confirmLoading={submitting}
            okText="Lưu thiết lập"
            cancelText="Hủy bỏ"
            okButtonProps={{ style: { backgroundColor: '#4318FF' } }}
            width={500}
            centered
            destroyOnClose
            title={
                <Space style={{ marginBottom: 12 }}>
                    <div style={{ backgroundColor: '#F5F3FF', padding: '8px', borderRadius: '50%', display: 'flex' }}>
                        <SettingOutlined style={{ color: '#4318FF', fontSize: '18px' }} />
                    </div>
                    <Text strong style={{ fontSize: 18, color: '#1E293B' }}>Chỉnh sửa thông số</Text>
                </Space>
            }
        >
            <div style={{ padding: '8px 0' }}>
                <div style={{ background: '#F8FAFC', padding: '16px', borderRadius: '12px', border: '1px dashed #CBD5E1', marginBottom: '24px' }}>
                    <Space direction="vertical" size={4} style={{ width: '100%' }}>
                        <Text type="secondary" style={{ fontSize: 12, textTransform: 'uppercase', letterSpacing: '1px', color: '#64748b' }}>
                            Mã hệ thống ({editingConfig?.type})
                        </Text>
                        <Title level={5} style={{ margin: 0, color: '#4318FF' }}>
                            {editingConfig?.key}
                        </Title>
                        <Paragraph type="secondary" style={{ fontSize: 13, marginTop: 8, marginBottom: 0, fontStyle: 'italic', color: '#475569' }}>
                            <InfoCircleOutlined /> {editingConfig?.description || 'Tham số ảnh hưởng trực tiếp đến tính toán của hệ thống.'}
                        </Paragraph>
                    </Space>
                </div>

                <Form form={form} layout="vertical" requiredMark={false}>
                    <Form.Item
                        name="value"
                        label={<Text strong style={{ color: '#1E293B' }}>Giá trị áp dụng mới</Text>}
                        rules={[{ required: true, message: 'Vui lòng không để trống!' }]}
                    >
                        {renderInputByType()}
                    </Form.Item>
                </Form>

                <Divider style={{ margin: '12px 0' }} />
                
                <div style={{ textAlign: 'center' }}>
                    <Text type="secondary" style={{ fontSize: 12, color: '#ef4444' }}>
                        ⚠️ Lưu ý: Thay đổi cấu hình sẽ có hiệu lực ngay lập tức trên toàn hệ thống.
                    </Text>
                </div>
            </div>
        </Modal>
    );
};

export default SystemConfigModal;