import React, { useEffect } from 'react';
import { Modal, Form, Input, InputNumber, Select, Typography, Space, Tag } from 'antd';
import { WalletOutlined, ArrowUpOutlined, ArrowDownOutlined } from '@ant-design/icons';

const { Option } = Select;
const { Text } = Typography;

const AdjustWalletModal = ({ isOpen, onClose, onSubmit, store }) => {
    const [form] = Form.useForm();

    useEffect(() => {
        if (isOpen) {
            form.resetFields();
        }
    }, [isOpen, form]);

    const handleOk = () => {
        form.validateFields()
            .then((values) => {
                onSubmit(values);
            })
            .catch((info) => {
                console.log('Validate Failed:', info);
            });
    };

    return (
        <Modal
            title={
                <Space align="center">
                    <div style={{ padding: '8px', background: '#e6f7ff', borderRadius: '50%', color: '#1890ff', display: 'flex' }}>
                        <WalletOutlined />
                    </div>
                    <span style={{ fontSize: '18px' }}>
                        Điều chỉnh ví: <Text strong type="success">{store?.name}</Text>
                    </span>
                </Space>
            }
            open={isOpen}
            onOk={handleOk}
            onCancel={onClose}
            okText="Xác nhận giao dịch"
            cancelText="Hủy bỏ"
            destroyOnHidden
            width={450}
            centered
            styles={{ body: { paddingTop: '16px' } }}
        >
            <Form
                form={form}
                layout="vertical"
                initialValues={{ type: 1 }}
                size="large"
            >
                <Form.Item
                    name="type"
                    label={<Text strong>Loại biến động</Text>}
                    rules={[{ required: true }]}
                >
                    <Select placeholder="Chọn hành động">
                        <Option value={1}><Space><Tag color="green"><ArrowUpOutlined /></Tag>Nạp tiền (Cộng vào)</Space></Option>
                        <Option value={4}><Space><Tag color="cyan"><ArrowUpOutlined /></Tag>Hoàn tiền (Cộng vào)</Space></Option>
                        <Option value={2}><Space><Tag color="volcano"><ArrowDownOutlined /></Tag>Thu hoa hồng (Trừ ra)</Space></Option>
                        <Option value={3}><Space><Tag color="red"><ArrowDownOutlined /></Tag>Thu phí(Trừ ra)</Space></Option>
                    </Select>
                </Form.Item>

                <Form.Item
                    name="amount"
                    label={<Text strong>Số tiền (VNĐ)</Text>}
                    rules={[{ required: true, message: 'Vui lòng nhập số tiền!' }]}
                >
                    <InputNumber
                        style={{ width: '100%' }}
                        formatter={(value) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
                        parser={(value) => value.replace(/\$\s?|(,*)/g, '')}
                        min={1000}
                        placeholder="Ví dụ: 500,000"
                    
                    />
                </Form.Item>

                <Form.Item
                    name="reason"
                    label={<Text strong>Lý do (Hiển thị cho cửa hàng thấy)</Text>}
                    rules={[{ required: true, message: 'Vui lòng nhập lý do!' }]}
                >
                    <Input.TextArea 
                        rows={3} 
                        placeholder="Ví dụ: Nạp tiền cọc, trừ phí vi phạm..." 
                        style={{ borderRadius: '8px' }}
                    />
                </Form.Item>
            </Form>
        </Modal>
    );
};

export default AdjustWalletModal;